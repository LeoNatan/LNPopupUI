//
//  TabDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct InnerView : View {
	let onDismiss: () -> Void
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			SafeAreaDemoView()
			Button("Gallery") {
				onDismiss()
			}.padding()
		}
	}
}

struct TabDemoView : View {
	@State private var isPopupPresented: Bool = true
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		TabView{
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popupDemo(isBarPresented: $isPopupPresented)
	}
}
