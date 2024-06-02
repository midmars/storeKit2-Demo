//
//  ContentView.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/4/15.
//

import SwiftUI
import StoreKit

struct ContentView: View {
	@StateObject var store: Store = Store()
	var body: some View {
		VStack(spacing: 20) {
			
			List{
				Section("自動訂閱"){
					ForEach(store.subscriptions) { product in
						ListProudCellView(product: product,
															purchasingEnabled: store.purchasedSubscriptions.isEmpty)
					}
				}
				Button("Restore Purchases", action: {
						Task {
								//This call displays a system prompt that asks users to authenticate with their App Store credentials.
								//Call this function only in response to an explicit user action, such as tapping a button.
								try? await AppStore.sync()
						}
				})
			}.listStyle(GroupedListStyle())
			
			
		}
	}
}

#Preview {
	ContentView()
}
