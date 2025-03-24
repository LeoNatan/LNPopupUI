//
//  NavDemoView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct NavDemoView : View {
	@State private var isBarPresented: Bool = true
	let title: String?
	
	let demoContent: DemoContent
	let onDismiss: () -> Void
	@Environment(\.colorScheme) private var environmentColorScheme
	@State private var forcedColorScheme: ColorScheme?
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	func appearanceHandler() {
		if let forcedColorScheme = forcedColorScheme {
			self.forcedColorScheme = forcedColorScheme == .dark ? .light : .dark
		} else {
			self.forcedColorScheme = environmentColorScheme == .dark ? .light : .dark
		}
	}
	
	var body: some View {
		MaterialNavigationStack {
			let bottomButtonsHandlers = SafeAreaDemoView.BottomButtonHandlers(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler)
			let bottomBarHideSupport = SafeAreaDemoView.BottomBarHideSupport(showsBottomBarHideButton: true)
			
			SafeAreaDemoView(colorSeed:"nil", includeToolbar: true, includeLink: true, bottomButtonsHandlers: bottomButtonsHandlers, showDismissButton: false, onDismiss: onDismiss, bottomBarHideSupport: bottomBarHideSupport)
				.navigationBarTitle(title ?? "LNPopupUI")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Gallery") {
							onDismiss()
						}
					}
				}
		}
		.colorScheme(forcedColorScheme ?? environmentColorScheme)
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
	}
}

struct NavDemoView_Previews: PreviewProvider {
	static var previews: some View {
		NavDemoView(title: nil, demoContent: DemoContent(), onDismiss: {})
	}
}
