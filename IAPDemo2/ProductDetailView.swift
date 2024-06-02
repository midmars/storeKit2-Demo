//
//  ProductDetailView.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/31.
//
import Foundation
import StoreKit
import SwiftUI

struct ProductDetailView: View {
	@EnvironmentObject var store: Store
	@StateObject var trans: TransactionManager = .init()
	var gridItemLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
	let product: Product
	let dateFormatter = DateFormatter()
	var body: some View {
		let expirationDate = getFomatterDate(date: trans.newTransaction?.expirationDate ?? Date())
		ZStack{
			Group {
				VStack {
					Text(product.displayName)
						.bold()
						.padding()
					Text(product.description)
					Text(product.displayPrice)
					Text(trans.newTransaction?.id.description ?? "")
					Text(expirationDate)
					List {
						LazyVGrid(columns: gridItemLayout, content: {
							Text("Id")
								.fontWeight(.bold)
							Text("OriginId")
								.fontWeight(.bold)
							Text("Expired")
								.fontWeight(.bold)
							Text("Price")
								.fontWeight(.bold)
							Text("Quantity")
								.fontWeight(.bold)
						})
						Section {
							ForEach(trans.transactionList) { transaction in

								ListTransactionView(transaction: transaction)
							}
						}
					}
				}
			}
		}
		.onAppear{
			Task{
				await trans.getLatestTranscationHistory(productId: product.id)
			}
		}
	}

	func getFomatterDate(date: Date) -> String {
		dateFormatter.dateFormat = "HH:mm:SS"
		return dateFormatter.string(from: date)
	}
}

struct ListTransactionView: View {
	let transaction: Transaction
	let dateFormatter = DateFormatter()
	var gridItemLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
	var body: some View {
		LazyVGrid(columns: gridItemLayout, content: {
			Text(transaction.id.description)
				.padding()
			Text(transaction.originalID.description)
				.padding()
			experiedView
			
			Text(priceFormatted)
			Text(transaction.purchasedQuantity.description)
		})
	}

	var experiedView: some View {
		let isNotExpired = transaction.expirationDate ?? Date() > Date()
		if isNotExpired {
			return Text("🟢")
		} else {
			return Text("🟡")
		}
	}

	var priceFormatted: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = transaction.currency?.identifier
		return formatter.string(from: transaction.price! as NSNumber) ?? "$0.00"
	}

	func getFomatterDate(date: Date) -> String {
		dateFormatter.dateFormat = "HH:mm:SS"
		return dateFormatter.string(from: date)
	}
}

// #Preview {
//    ProductDetailView()
// }
