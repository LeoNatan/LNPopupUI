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
		let nav = MaterialNavigationStack {
			InnerView(tabIdx: idx, showDismissButton: false, onDismiss: onDismiss, includeToolbar: !isGlobal, presentBarHandler: nil, hideBarHandler: nil)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Gallery") {
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
		let splitView = MaterialNavigationSplitView(columnVisibility: Binding.constant(.all), preferredCompactColumn: Binding.constant(.content)) {
			SplitInnerView(title: "Sidebar", idx: 600, isGlobal: isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(min: 400, ideal: 400, max: 400)
		} content: {
			SplitInnerView(title: "Content", idx: 2000, isGlobal: isGlobal, onDismiss: onDismiss)
				.navigationSplitViewColumnWidth(min: 400, ideal: 400, max: 400)
		} detail: {
			SplitInnerView(title: "Detail", idx: 1, isGlobal: isGlobal, onDismiss: onDismiss)
		}
		.navigationSplitViewStyle(.prominentDetail)
		
		if isGlobal {
			splitView.popupDemo(demoContent: DemoContent(), isBarPresented: Binding.constant(true), includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		} else {
			splitView
		}
	}
}
