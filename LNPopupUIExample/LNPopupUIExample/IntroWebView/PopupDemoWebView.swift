//
//  PopupDemoWebView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2021-09-25.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
	let url: URL
	
	func makeUIView(context: Context) -> WKWebView  {
		return WKWebView()
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		uiView.load(URLRequest(url: url))
	}
	
}

let url = URL(string: "https://github.com/LeoNatan/LNPopupUI")!

struct PopupDemoWebView: View {
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				WebView(url: url)
				Color(red: 0.12, green:0.14, blue:0.15)
//				BlurView()
					.frame(maxWidth: .infinity, minHeight: geometry.safeAreaInsets.top, maxHeight: geometry.safeAreaInsets.top)
			}
			.ignoresSafeArea(.all)
			.popupBarStyle(.floating)
			.popupTitle {
				HStack {
					Text("Welcome to ") + Text("LNPopupUI").fontWeight(.heavy) + Text("!")
				}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			}
			.popupImage(Image("AppIconPopupBar"))
			.popupBarItems({
				ToolbarItemGroup(placement: .popupBar) {
					Link(destination: url) {
						Image(systemName: "suit.heart.fill")
					}
				}
			})
		}
	}
}
