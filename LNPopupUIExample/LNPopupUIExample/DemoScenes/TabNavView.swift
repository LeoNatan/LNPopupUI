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
	let tabIdx: Int
	let onDismiss: () -> Void
	
	var body: some View {
		NavigationView {
			SafeAreaDemoView(colorSeed:"tab_\(tabIdx)", includeLink: true, showDismissButton: false, onDismiss: onDismiss)
				.navigationBarTitle("Tab View + Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarItems(trailing: Button("Gallery") {
					onDismiss()
				})
		}
		.navigationViewStyle(.stack)
	}
}

struct TabNavView : View {
	@State private var isBarPresented: Bool = true
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
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented)
	}
}

struct TabNavView_Previews: PreviewProvider {
	static var previews: some View {
		TabNavView(demoContent: DemoContent(), onDismiss: {})
	}
}
