//
//  TabNavView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct InnerNavView : View {
	let onDismiss: () -> Void
	
	var body: some View {
		NavigationView {
			SafeAreaDemoView(includeLink: true)
				.navigationBarTitle("Tab View + Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarItems(trailing: Button("Gallery") {
					onDismiss()
				})
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct TabNavView : View {
	@State private var isPopupPresented: Bool = true
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		TabView{
			InnerNavView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popupDemo(isBarPresented: $isPopupPresented)
	}
}
