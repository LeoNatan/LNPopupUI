//
//  TabNavView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct RestoreTabBarModifier: ViewModifier {
	let restoreTabBar: (() -> Void)?
	
	@ViewBuilder func body(content: Content) -> some View {
		if restoreTabBar != nil {
			content.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						restoreTabBar?()
					} label: {
						Image(systemName: "rectangle.bottomthird.inset.fill")
					}
				}
			}
		} else {
			content
		}
	}
}

struct InnerNavView : View {
	let tabIdx: Int
	let onDismiss: () -> Void
	
	let presentBarHandler: () -> Void
	let hideBarHandler: () -> Void
	let restoreTabBar: (() -> Void)?
	
	var body: some View {
		MaterialNavigationStack {
			SafeAreaDemoView(colorSeed:"tab_\(tabIdx)", includeLink: true, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, showDismissButton: true, onDismiss: onDismiss)
				.navigationBarTitle("Tab View + Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.modifier(RestoreTabBarModifier(restoreTabBar: restoreTabBar))
		}
	}
}

struct TabNavView : View {
	@State private var isBarPresented: Bool = true
	@State private var isTabBarPresented: Bool = true
	
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
			InnerNavView(tabIdx:0, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, restoreTabBar: nil)
				.tabItem {
					Label("Tab", systemImage: "1.square")
				}
			InnerNavView(tabIdx:1, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, restoreTabBar: nil)
				.tabItem {
					Label("Tab", systemImage: "2.square").foregroundStyle(.red)
				}
			InnerNavView(tabIdx:2, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, restoreTabBar: nil)
				.tabItem {
					Label("Tab", systemImage: "3.square")
				}
			InnerNavView(tabIdx:3, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, restoreTabBar: nil)
				.tabItem {
					Label("Tab", systemImage: "4.square")
				}
			InnerNavView(tabIdx:4, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler, restoreTabBar: isTabBarPresented ? nil : {
				isTabBarPresented = true
			}).onAppear() {
				isTabBarPresented = false
			}
			.tabItem {
				Label("Hide Bar", systemImage: "xmark.square")
			}
			.toolbar(isTabBarPresented ? .visible : .hidden, for: .tabBar)
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: PopupSettingsContextMenuEnabled))
	}
}

struct TabNavView_Previews: PreviewProvider {
	static var previews: some View {
		TabNavView(demoContent: DemoContent(), onDismiss: {})
	}
}
