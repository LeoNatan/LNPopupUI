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
		MaterialTabView {
			InnerView(tabIdx:0, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Label("Tab", systemImage: "1.square")
				}
			InnerView(tabIdx:1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Label("Tab", systemImage: "2.square")
				}
			InnerView(tabIdx:2, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Label("Tab", systemImage: "3.square")
				}
			InnerView(tabIdx:3, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Label("Tab", systemImage: "4.square")
				}
			InnerView(tabIdx:4, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.tabItem {
					Label("Hide Bar", systemImage: "xmark.square")
				}
				.toolbar(.hidden, for: .tabBar)
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled), includeCustomTextLabels: true)
	}
}

struct TabNavViewCustomLabels_Previews: PreviewProvider {
	static var previews: some View {
		TabViewCustomLabels(demoContent: DemoContent(), onDismiss: {})
	}
}
