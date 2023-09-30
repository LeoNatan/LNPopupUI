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
	let demoContent: DemoContent
	let onDismiss: () -> Void
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		TabView{
			InnerView(tabIdx:0, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:2, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:3, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:4, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Hide Bar")
				}
				.toolbar(.hidden, for: .tabBar)
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.standard.bool(forKey: PopupSettingsContextMenuEnabled), includeCustomTextLabels: true)
	}
}

struct TabNavViewCustomLabels_Previews: PreviewProvider {
	static var previews: some View {
		TabViewCustomLabels(demoContent: DemoContent(), onDismiss: {})
	}
}
