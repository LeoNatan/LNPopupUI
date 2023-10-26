//
//  TabDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI
import LNSwiftUIUtils

struct InnerView : View {
	let tabIdx: Int?
	let showDismissButton: Bool?
	let onDismiss: () -> Void
	
	let presentBarHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?

	init(tabIdx: Int?, showDismissButton: Bool? = true, onDismiss: @escaping () -> Void, presentBarHandler: (() -> Void)?, hideBarHandler: (() -> Void)?) {
		self.tabIdx = tabIdx
		self.showDismissButton = showDismissButton
		self.onDismiss = onDismiss
		self.presentBarHandler = presentBarHandler
		self.hideBarHandler = hideBarHandler
	}
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			SafeAreaDemoView(colorSeed: tabIdx != nil ? (tabIdx! == -1 ? "tab_\(Int.random(in: 0..<1000))" : "tab_\(tabIdx!)") : "nil", presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, showDismissButton: showDismissButton)
			if let showDismissButton, showDismissButton == true {
				VStack {
					Button("Gallery") {
						onDismiss()
					}.fontWeight(.semibold)
					.padding([.leading, .trailing])
				}.padding(.top, 4)
			}
		}
	}
}

struct TabDemoView : View {
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
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.standard.bool(forKey: PopupSettingsContextMenuEnabled))
	}
}

struct TabDemoView_Previews: PreviewProvider {
	static var previews: some View {
		TabDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
