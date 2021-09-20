//
//  TabNavViewCustomLabels.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/20/21.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct TabNavViewCustomLabels : View {
	@State private var isBarPresented: Bool = true
	@State private var isPopupOpen: Bool = false
	private let onDismiss: () -> Void
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		self.demoContent = demoContent
	}
	
	var body: some View {
		TabView{
			InnerNavView(tabIdx:0, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:1, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:2, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:3, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:4, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, isPopupOpen: $isPopupOpen, includeCustomTextLabels: true)
	}
}

struct TabNavViewCustomLabels_Previews: PreviewProvider {
	static var previews: some View {
		TabNavViewCustomLabels(demoContent: DemoContent(), onDismiss: {})
	}
}
