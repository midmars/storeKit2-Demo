//
//  Transaction.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/31.
//

import Foundation
import StoreKit

class TransactionManager: ObservableObject {
	@Published private(set) var transactionList: [Transaction]
	@Published private(set) var newTransaction: Transaction? = nil

	init() {
		transactionList = []
		Task {
			await getTransactionList()
		}
	}

	@MainActor func getTransactionList() async {
		do {
			let currentEntitlements = try await Transaction.all
			for await result in currentEntitlements {
				// 處理訂閱交易
				let transaction = try checkVerified(result)
				transactionList.append(transaction)
				print("Product ID: \(transaction.productID)")
				print("Purchase Date: \(transaction.purchaseDate)")
				print("Expiry Date: \(transaction.expirationDate ?? Date())")
			}
		} catch {
			print("Failed to fetch current entitlements: \(error)")
		}
	}
	
	@MainActor
	func getLatestTranscationHistory(productId: String) async {
			do {
				if let latestResult = try await Transaction.latest(for: productId) {
					// 處理最新訂閱交易
					let latestTransaction = try checkVerified(latestResult)
					newTransaction = latestTransaction
					print("Product ID: \(latestTransaction.productID)")
					print("Purchase Date: \(latestTransaction.purchaseDate)")
					print("Expiry Date: \(latestTransaction.expirationDate ?? Date())")
				}
			} catch {
				print("Failed to fetch latest transaction: \(error)")
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
}
