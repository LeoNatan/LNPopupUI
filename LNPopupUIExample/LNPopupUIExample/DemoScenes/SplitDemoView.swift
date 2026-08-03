//
//  SplitDemoView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2023-10-24.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

struct SplitInnerView: View {
	let title: String
	let idx: Int
	let isGlobal: Bool
	let onDismiss: () -> Void
	
	var body: some View {
		let nav = NavigationStack {
			InnerView(tabIdx: idx, onDismiss: onDismiss, includeToolbar: false, presentBarHandler: nil, hideBarHandler: nil, noCloseButton: true)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						ToolbarCloseButton {
							onDismiss()
						}
					}
				}
				.navigationTitle(title)
				.navigationBarTitleDisplayMode(.inline)
		}
		
		if isGlobal {
			nav
		} else {
			nav.popupDemo(demoContent: DemoContent(), isBarPresented: Binding.constant(true), includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
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
		if isGlobal {
			globalSplitView()
				.popupDemo(demoContent: DemoContent(), isBarPresented: Binding.constant(true), includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		} else {
			fullSplitView()
		}
	}
	
	@ViewBuilder
	func globalSplitView() -> some View {
		NavigationSplitView(columnVisibility: Binding.constant(.all), preferredCompactColumn: Binding.constant(.content)) {
			SplitInnerView(title: "Sidebar", idx: 600, isGlobal: isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(min: 270, ideal: 320, max: 450)
		} detail: {
			SplitInnerView(title: "Detail", idx: 1, isGlobal: isGlobal, onDismiss: onDismiss)
		}.navigationSplitViewStyle(.balanced)
	}
	
	@ViewBuilder
	func fullSplitView() -> some View {
		NavigationSplitView(columnVisibility: Binding.constant(.doubleColumn), preferredCompactColumn: Binding.constant(.content)) {
			SplitInnerView(title: "Sidebar", idx: 600, isGlobal: isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(320)
		} content: {
			SplitInnerView(title: "Content", idx: 16, isGlobal: isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(320)
		} detail: {
			SplitInnerView(title: "Detail", idx: 1, isGlobal: isGlobal, onDismiss: onDismiss)
		}.navigationSplitViewStyle(.balanced)
	}
}
