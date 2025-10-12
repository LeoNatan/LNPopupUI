//
//  PopupDemoWebView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2021-09-25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
	let url: URL
	
	func makeUIView(context: Context) -> WKWebView  {
		let rv = WKWebView()
#if compiler(>=6.2)
		if #available(iOS 26.0, *) {
			rv.scrollView.topEdgeEffect.isHidden = true
		}
#endif
		return rv
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.load(URLRequest(url: url))
	}
	
}

let url = URL(string: "https://github.com/LeoNatan/LNPopupUI")!

struct PopupDemoWebView: View {
	@Environment(\.font) var inheritedFont
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				WebView(url: url)
				Color(red: 0.12, green:0.14, blue:0.15)
//				BlurView()
					.frame(maxWidth: .infinity, minHeight: geometry.safeAreaInsets.top, maxHeight: geometry.safeAreaInsets.top)
			}
			.ignoresSafeArea(.all)
			.popupTitle {
				HStack {
					Text(NSLocalizedString("Welcome to ", comment: "")) + Text(NSLocalizedString("LNPopupUI", comment: "")).fontWeight(.heavy) + Text("!")
				}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).font(inheritedFont ?? .body)
			}
			.popupImage(Image("AppIconPopupBar"))
			.popupBarItems {
				ToolbarItemGroup(placement: .popupBar) {
					Link(destination: url) {
						Image(systemName: "suit.heart.fill")
					}
				}
			}
		}
	}
}
