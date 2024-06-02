//
//  BuyButtonStyle.swift
//  IAPDemo2
//
//  Created by 陳耕霈 on 2024/5/31.
//

import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
	
	let isPurchased: Bool
	
	init(isPurchased: Bool = false) {
		self.isPurchased = isPurchased
	}
	
	func makeBody(configuration: Configuration) -> some View {
		var bgColor: Color = isPurchased ? Color.green : Color.cyan
		
		bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1.0)
		
		return configuration.label
			.frame(width: 100, height: 50)
			.padding(10)
			.background(bgColor)
			.clipShape(RoundedRectangle(cornerRadius: 20, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
			.scaleEffect(configuration.isPressed ? 0.9 : 1.0)
	}
}

struct BuyButtonStyle_Previews: PreviewProvider {
		static var previews: some View {
				Group {
						Button(action: {}) {
								Text("Buy")
										.foregroundColor(.white)
										.bold()
						}
						.buttonStyle(BuyButtonStyle())
						.previewDisplayName("Normal")
						
						Button(action: {}) {
								Image(systemName: "checkmark")
										.foregroundColor(.white)
						}
						.buttonStyle(BuyButtonStyle(isPurchased: true))
						.previewDisplayName("Purchased")
				}
		}
}
