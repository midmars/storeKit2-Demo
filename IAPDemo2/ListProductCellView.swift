//
//  ListProductCellView.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/30.
//

import SwiftUI
import StoreKit
struct ListProudCellView: View {
	@EnvironmentObject var store: Store
	@State var isPurchased: Bool = false
	@State var errorTitle = ""
	@State var isShowingError: Bool = false
	let product: Product
	let purchasingEnabled: Bool
	init(product: Product, purchasingEnabled: Bool = true) {
		self.product = product
		self.purchasingEnabled = purchasingEnabled
	}
	var body: some View {
		HStack{
			if purchasingEnabled {
				productDetail
				Spacer()
				buyButton
					.buttonStyle(BuyButtonStyle(isPurchased: isPurchased))
					.disabled(isPurchased)
			} else {
				productDetail
			}
		}
		.padding(
			EdgeInsets(top: 25, leading: 5, bottom: 25, trailing: 5)
		)
		.alert(isPresented: $isShowingError,content: {
			Alert(title: Text(errorTitle),message: nil,dismissButton: .default(Text("OKAY")))
		})
	}
	@ViewBuilder
	var productDetail: some View {
			if product.type == .autoRenewable {
					VStack(alignment: .leading) {
							Text(product.displayName)
									.bold()
							Text(product.description)
					}
			} else {
					Text(product.description)
							.frame(alignment: .leading)
			}
	}
	var buyButton: some View {
		Button(action: {
			Task {
				await buy()
			}
		}) {
			if isPurchased {
				Text(Image(systemName: "checkmark"))
					.bold()
					.foregroundColor(.white)
			} else {
				Text(product.displayPrice)
					.foregroundColor(.white)
					.bold()
			}
		}
	}
	func buy() async {
			do {
					if try await store.purchase(product) != nil {
							withAnimation {
									isPurchased = true
							}
					}
			} catch StoreError.failedVerification {
					errorTitle = "Your purchase could not be verified by the App Store."
					isShowingError = true
			} catch {
					print("Failed purchase for \(product.id): \(error)")
			}
	}
}

