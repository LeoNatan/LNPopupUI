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
	@State private var isPopupOpen: Bool = false
	let demoContent: DemoContent
	let onDismiss: () -> Void
	@Environment(\.colorScheme) private var environmentColorScheme
	@State private var forcedColorScheme: ColorScheme?
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func appearanceHandler() {
		if let forcedColorScheme = forcedColorScheme {
			self.forcedColorScheme = forcedColorScheme == .dark ? .light : .dark
		} else {
			self.forcedColorScheme = environmentColorScheme == .dark ? .light : .dark
		}
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		NavigationView {
			SafeAreaDemoView(includeLink: true, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler, showDismissButton: false, onDismiss: onDismiss)
				.navigationBarTitle("Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.demoToolbar(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler)
				.navigationBarItems(trailing: Button("Gallery") {
					onDismiss()
				})
		}
		.colorScheme(forcedColorScheme ?? environmentColorScheme)
		.navigationViewStyle(StackNavigationViewStyle())
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, isPopupOpen: $isPopupOpen)
	}
}

struct NavDemoView_Previews: PreviewProvider {
	static var previews: some View {
		NavDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
