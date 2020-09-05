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
	@State private var isPopupPresented: Bool = true
	private let onDismiss: () -> Void
	@Environment(\.colorScheme) private var environmentColorScheme
	@State private var forcedColorScheme: ColorScheme?
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		NavigationView {
			ConstraintsDemoView()
				.navigationBarTitle("Navigation View")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .bottomBar) {
						Button("Present Bar") {
							isPopupPresented = true
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
							isPopupPresented = false
						}
					}
				}
				.navigationBarItems(trailing: Button("Gallery") {
					onDismiss()
				})
		}
		.colorScheme(forcedColorScheme ?? environmentColorScheme)
		.navigationViewStyle(StackNavigationViewStyle())
		.popup(isBarPresented: $isPopupPresented, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			ZStack {
				Color.red.ignoresSafeArea()
				ConstraintsDemoView(includeLink: false)
			}
			.popupTitle(LoremIpsum.title, subtitle: LoremIpsum.sentence)
			.popupImage(Image("genre\(Int.random(in: 1..<31))"))
			.popupBarItems({
				HStack(spacing: 20) {
					Button(action: {
						print("Play")
					}) {
						Image(systemName: "play.fill")
					}
					
					Button(action: {
						print("Next")
					}) {
						Image(systemName: "forward.fill")
					}
				}
				.font(.system(size: 20))
			})
		}
		.popupCloseButtonStyle(.round)
	}
}
