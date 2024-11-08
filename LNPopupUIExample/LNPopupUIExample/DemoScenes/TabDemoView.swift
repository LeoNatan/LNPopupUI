//
//  TabDemoView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI
import LNSwiftUIUtils

struct InnerView : View {
	let tabIdx: Int?
	let showDismissButton: Bool?
	let onDismiss: () -> Void
	
	let includeToolbar: Bool
	let presentBarHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	init(tabIdx: Int?, showDismissButton: Bool? = true, onDismiss: @escaping () -> Void, includeToolbar: Bool = false, presentBarHandler: (() -> Void)?, hideBarHandler: (() -> Void)?) {
		self.tabIdx = tabIdx
		self.showDismissButton = showDismissButton
		self.onDismiss = onDismiss
		self.includeToolbar = includeToolbar
		self.presentBarHandler = presentBarHandler
		self.hideBarHandler = hideBarHandler
	}
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			let bottomButtonsHandlers = SafeAreaDemoView.BottomButtonHandlers(presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
			
			SafeAreaDemoView(colorSeed: tabIdx != nil ? (tabIdx! == -1 ? "tab_\(Int.random(in: 0..<1000))" : "tab_\(tabIdx!)") : "nil", includeToolbar: includeToolbar, bottomButtonsHandlers: bottomButtonsHandlers, showDismissButton: showDismissButton)
			if let showDismissButton, showDismissButton == true {
				VStack {
					Button("Gallery") {
						onDismiss()
					}
					.fontWeight(.semibold)
					.padding(7)
					.hoverEffect()
				}
				.padding(.top, horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad ? 27 : 0)
				.padding(.trailing, 8)
				.ignoresSafeArea(edges: horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad ? .top : .bottom)
			}
		}
	}
}

struct TabDemoView : View {
	let demoContent: DemoContent
	let onDismiss: () -> Void
	@State private var isBarPresented: Bool = true
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		TabGeneratorView(demoContent: demoContent, isBarPresented: $isBarPresented, tabContentGenerator: { idx in
			InnerView(tabIdx:idx, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
				.fixBottomBarAppearance()
		})
	}
}

struct TabDemoView_Previews: PreviewProvider {
	static var previews: some View {
		TabDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
