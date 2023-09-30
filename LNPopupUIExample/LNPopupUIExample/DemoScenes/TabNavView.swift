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
	
	let presentBarHandler: () -> Void
	let hideBarHandler: () -> Void
	
	var body: some View {
		NavigationStack {
			SafeAreaDemoView(colorSeed:"tab_\(tabIdx)", includeLink: true, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, showDismissButton: false, onDismiss: onDismiss)
				.navigationBarTitle("Tab View + Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarItems(trailing: Button("Gallery") {
					onDismiss()
				})
		}
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
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		TabView{
			InnerNavView(tabIdx:0, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:2, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:3, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerNavView(tabIdx:4, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Hide Bar")
				}
				.toolbar(.hidden, for: .tabBar)
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.standard.bool(forKey: PopupSettingsContextMenuEnabled))
	}
}

struct TabNavView_Previews: PreviewProvider {
	static var previews: some View {
		TabNavView(demoContent: DemoContent(), onDismiss: {})
	}
}
