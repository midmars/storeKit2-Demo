//
//  Store.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/30.
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
	case failedVerification
}

public enum SubscriptionTier: Int, Comparable {
	case none = 0
	case standard = 1
	case premium = 2
	case pro = 3

	public static func <(lhs: Self, rhs: Self) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}

class Store: ObservableObject {
	@Published private(set) var subscriptions: [Product] // 訂閱項目List
	@Published private(set) var nonRenewables: [Product]
	
	@Published private(set) var purchasedNonRenewableSubscriptions: [Product] = []
	@Published private(set) var purchasedSubscriptions: [Product] = []
	@Published private(set) var subscriptionGroupStatus: RenewalState?

	let productIds = ["subscription.monthly", "subscription.yearly"]

	var updateListenerTask: Task<Void, Error>? = nil

	init() {
		subscriptions = []
		nonRenewables = []

		// Start a transaction listener as close to app launch as possible so you don't miss any transactions.
		updateListenerTask = listenForTransactions()
		Task{
			await requestProducts()
			
			await updateCustomerProductStatus()
		}
	}

	deinit {
		updateListenerTask?.cancel()
	}

	@MainActor func requestProducts() async {
		do {
			let storeProducts = try await Product.products(for: productIds)

			for product in storeProducts {
				switch product.type {
				case .autoRenewable:
					subscriptions.append(product)
				case .nonRenewable:
					nonRenewables.append(product)
				default:
					// Ignore this product.
					print("Unknown product")
				}
			}
			subscriptions = sortByPrice(data: subscriptions)
			nonRenewables = sortByPrice(data: nonRenewables)
		} catch {
			print("Failed product request from the App Store server: \(error)")
		}
	}

	func listenForTransactions() -> Task<Void, Error> {
		return Task.detached{
			// Iterate through any transactions that don't come from a direct call to `purchase()`.
			for await result in Transaction.updates {
				do {
					let transcation = try self.checkVerified(result)

					await self.updateCustomerProductStatus()

					await transcation.finish()
				} catch {
					// StoreKit has a transaction that fails verification. Don't deliver content to the user.
					print("Transaction failed verification")
				}
			}
		}
	}

	func purchase(_ product: Product) async throws -> Transaction? {
		let uuid = Product.PurchaseOption.appAccountToken(UUID())
		let result = try await product.purchase(options: [uuid])

		switch result {
		case .success(let verification):
			let transaction = try checkVerified(verification)
			// The transaction is verified. Deliver content to the user.
			await updateCustomerProductStatus()

			await transaction.finish()

			return transaction
		case .userCancelled, .pending:
			return nil
		default:
			return nil
		}
	}

	func isPurchase(_ product: Product) async -> Bool {
		switch product.type {
		case .autoRenewable:
			return purchasedSubscriptions.contains(product)
		default:
			return false
		}
	}

	func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		// Check whether the JWS passes StoreKit verification.
		switch result {
		case .unverified:
			// StoreKit parses the JWS, but it fails verification.
			throw StoreError.failedVerification
		case .verified(let safe):
			// The result is verified. Return the unwrapped value.
			return safe
		}
	}

	@MainActor func updateCustomerProductStatus() async {
		var purchasedSubscriptions: [Product] = []

		for await result in Transaction.currentEntitlements {
			do {
				// Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
				let transaction = try checkVerified(result)
				switch transaction.productType {
				case .autoRenewable:
					if let subscription = subscriptions.first( where: {$0.id == transaction.productID}) {
						purchasedSubscriptions.append(subscription)
					}
				default:
					break
				}
			} catch {
				print(error.localizedDescription)
			}
		}
		
		self.purchasedSubscriptions = purchasedSubscriptions
		//Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
		//is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
		//group, so products in the subscriptions array all belong to the same group. The statuses that
		//`product.subscription.status` returns apply to the entire subscription group.
		do {
			subscriptionGroupStatus = try await subscriptions.first?.subscription?.status.first?.state
		} catch {
			print()
		}
	}

	func sortByPrice(data: [Product]) -> [Product] {
		return data.sorted{ $0.price < $1.price }
	}
}
