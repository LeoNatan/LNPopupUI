//
//  TabViewCustomLabels.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/20/21.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct TabViewCustomLabels : View {
	@State private var isBarPresented: Bool = true
	private let onDismiss: () -> Void
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		self.demoContent = demoContent
	}
	
	var body: some View {
		TabView{
			InnerView(tabIdx:0, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:1, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:2, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:3, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:4, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeCustomTextLabels: true)
	}
}

struct TabNavViewCustomLabels_Previews: PreviewProvider {
	static var previews: some View {
		TabViewCustomLabels(demoContent: DemoContent(), onDismiss: {})
	}
}
