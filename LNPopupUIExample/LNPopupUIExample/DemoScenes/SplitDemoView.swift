//
//  SplitDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 23/10/2023.
//

import SwiftUI

struct SplitInnerView: View {
	let isGlobal: Bool
	let showsToolbarItems: Bool
	let showsTabBarItems: Bool
	let onDismiss: () -> Void
	
	init(isGlobal: Bool, showsToolbarItems: Bool = false, showsTabBarItems: Bool = false, onDismiss: @escaping () -> Void) {
		self.isGlobal = isGlobal
		self.showsToolbarItems = showsToolbarItems
		self.showsTabBarItems = showsTabBarItems
		self.onDismiss = onDismiss
	}
	
	@ViewBuilder func tabViewOrInner<Content: View>(inner: Content) -> some View {
		if showsTabBarItems {
			MaterialTabView {
				inner
			}
		} else {
			inner
		}
	}
	
	var body: some View {
		let inner = tabViewOrInner(inner: InnerView(tabIdx: -1, showDismissButton: false, onDismiss: onDismiss, presentBarHandler: nil, hideBarHandler: nil)
			.tabItem {
				Image(systemName: "star")
				Text("Tab")
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Gallery") {
						onDismiss()
					}
				}
				if showsToolbarItems {
					ToolbarItemGroup(placement: .bottomBar) {
						Button("Test 1") {
							
						}
						Spacer()
						Button("Test 2") {
							
						}
						Spacer()
						Button("Test 3") {
							
						}
					}
				}
			})
		
		
		if isGlobal == false {
			inner.popupDemo(demoContent: DemoContent(), isBarPresented: Binding.constant(true), includeContextMenu: UserDefaults.standard.bool(forKey: PopupSettingsContextMenuEnabled))
		} else {
			inner
		}
	}
}

@available(iOS 17.0, *)
struct SplitDemoView: View {
	let isGlobal: Bool
	let onDismiss: () -> Void
	
	init(isGlobal: Bool, onDismiss: @escaping () -> Void) {
		self.isGlobal = isGlobal
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		let splitView = MaterialNavigationSplitView(columnVisibility: Binding.constant(.all), preferredCompactColumn: Binding.constant(.content)) {
			SplitInnerView(isGlobal:isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(min: 400, ideal: 400, max: 400)
				.navigationTitle("Sidebar")
		} content: {
			SplitInnerView(isGlobal:isGlobal, showsToolbarItems: isGlobal == false, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(min: 400, ideal: 400, max: 400)
				.navigationTitle("Content")
		} detail: {
			SplitInnerView(isGlobal:isGlobal, showsTabBarItems: isGlobal == false, onDismiss: onDismiss)
				.navigationTitle("Detail")
		}
		.navigationSplitViewStyle(.prominentDetail)
		
		if isGlobal {
			splitView.popupDemo(demoContent: DemoContent(), isBarPresented: Binding.constant(true), includeContextMenu: UserDefaults.standard.bool(forKey: PopupSettingsContextMenuEnabled))
		} else {
			splitView
		}
	}
}
