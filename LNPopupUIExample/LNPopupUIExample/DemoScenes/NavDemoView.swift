//
//  NavDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct NavDemoView : View {
	@State private var isBarPresented: Bool = true
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
			SafeAreaDemoView(colorSeed:"nil", includeToolbar: true, includeLink: true, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler, showDismissButton: false, onDismiss: onDismiss)
				.navigationBarTitle("Navigation View")
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
		NavDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
