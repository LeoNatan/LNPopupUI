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
	
	var body: some View {
		NavigationView {
			SafeAreaDemoView(includeLink: true, onDismiss: onDismiss)
				.navigationBarTitle("Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .bottomBar) {
						Button("Present Bar") {
							isBarPresented = true
						}
					}
					ToolbarItem(placement: .bottomBar) {
						Spacer()
					}
					ToolbarItem(placement: .bottomBar) {
						Button("Appearance") {
							if let forcedColorScheme = forcedColorScheme {
								self.forcedColorScheme = forcedColorScheme == .dark ? .light : .dark
							} else {
								forcedColorScheme = environmentColorScheme == .dark ? .light : .dark
							}
						}
					}
					ToolbarItem(placement: .bottomBar) {
						Spacer()
					}
					ToolbarItem(placement: .bottomBar) {
						Button("Dismiss Bar") {
							isBarPresented = false
						}
					}
				}
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
