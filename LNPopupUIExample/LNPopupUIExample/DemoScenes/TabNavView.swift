//
//  TabNavView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct ToolbarRolePad18Modifier: ViewModifier {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
	func body(content: Content) -> some View {
		return content.toolbarRole(UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular ? .editor : .navigationStack)
	}
}

extension View {
	func toolbarRoleIfPad18() -> some View {
		if #available(iOS 18.0, *) {
			return self.modifier(ToolbarRolePad18Modifier())
		} else {
			return self
		}
	}
}

struct InnerNavView : View {
	
	
	let tabIdx: Int
	let onDismiss: () -> Void
	
	let presentBarHandler: () -> Void
	let hideBarHandler: () -> Void
	
	var body: some View {
		MaterialNavigationStack {
			let bottomButtonsHandlers = SafeAreaDemoView.BottomButtonHandlers(presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
			let bottomBarHideSupport = SafeAreaDemoView.BottomBarHideSupport(showsBottomBarHideButton: true, isBottomBarTab: true)
			
			SafeAreaDemoView(colorSeed: "tab_\(tabIdx)", includeLink: true, bottomButtonsHandlers: bottomButtonsHandlers, showDismissButton: true, onDismiss: onDismiss, bottomBarHideSupport: bottomBarHideSupport)
				.navigationBarTitle("Tab View + Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.toolbarRoleIfPad18()
		}
	}
}

struct TabNavView : View {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
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
		if #available(iOS 18.0, *) {
			MaterialTabView {
				ForEach(1..<5) { idx in
					Tab("Tab\(UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular ? " \(idx)" : "")", systemImage: "\(idx).square") {
						InnerNavView(tabIdx:idx - 1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
					}
				}
			}
			.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		} else {
			MaterialTabView {
				ForEach(1..<5) { idx in
					InnerNavView(tabIdx:idx - 1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
						.tabItem {
							Label("Tab", systemImage: "\(idx).square").foregroundStyle(.red)
						}
				}
			}
			.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		}
	}
}

struct TabNavView_Previews: PreviewProvider {
	static var previews: some View {
		TabNavView(demoContent: DemoContent(), onDismiss: {})
	}
}
