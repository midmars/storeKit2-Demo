//
//  HomeView.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/31.
//

import SwiftUI

struct HomeView: View {
	@StateObject var store: Store = .init()
	var body: some View {
		NavigationStack{
			if store.purchasedSubscriptions.isEmpty &&
				store.purchasedNonRenewableSubscriptions.isEmpty {
				VStack {
					Text("StoreKit deom app")
						.bold()
						.font(.system(size: 50))
						.padding(.bottom, 20)
					Text("測試訂閱制 實作以及訂閱紀錄💪🏽💪🏽💪🏽")
						.font(.headline)
						.padding()
						.multilineTextAlignment(.center)
					NavigationLink{
						ContentView()
					} label: {
						Label("Shop", systemImage: "cart")
							.font(.headline)
							.foregroundColor(.white)
							.padding()
							.frame(width: 300, height: 50, alignment: .center)
							.background(Color.blue)
							.cornerRadius(15.0)
					}
				}
			} else {
				List {
					Section("你擁有的服務") {
						if !store.purchasedSubscriptions.isEmpty {
							ForEach(store.purchasedSubscriptions) {
								product in
								NavigationLink {
									ProductDetailView(product: product)
								} label: {
									ListProudCellView(product: product, purchasingEnabled: false)
								}
							}
						}
					}

					NavigationLink {
						ContentView()
					} label: {
						Label("Shop", systemImage: "cart")
					}
					.foregroundColor(.white)
					.listRowBackground(Color.blue)
				}
				.navigationTitle("StoreKit deom app")
			}
		}
		.environmentObject(store)
	}
}

#Preview {
	HomeView()
}
