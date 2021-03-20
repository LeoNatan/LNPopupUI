//
//  SafeAreaDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LNPopupUI
import LNPopupController
import LoremIpsum

extension View {
	@ViewBuilder
	func ifLet<V, Transform: View>(
		_ value: V?,
		transform: (Self, V) -> Transform
	) -> some View {
		if let value = value {
			transform(self, value)
		} else {
			self
		}
	}
	
	@ViewBuilder
	func `if`<Transform: View>(
		_ value: Bool,
		transform: (Self) -> Transform
	) -> some View {
		if value {
			transform(self)
		} else {
			self
		}
	}
}

struct SafeAreaDemoView : View {
	let includeLink: Bool
	let offset: Bool
	let isPopupOpen: Binding<Bool>?
	let onDismiss: (() -> Void)?
	let colorSeed: String
	let colorIndex: Int
	
	init(colorSeed: String = "nil", colorIndex: Int = 0, includeLink: Bool = false, offset: Bool = false, isPopupOpen: Binding<Bool>? = nil, onDismiss: (() -> Void)? = nil) {
		self.includeLink = includeLink
		self.offset = offset
		self.isPopupOpen = isPopupOpen
		self.onDismiss = onDismiss
		self.colorSeed = colorSeed
		self.colorIndex = colorIndex
	}
	
	var body: some View {
		ZStack(alignment: .trailing) {
			VStack {
				Text("Top").offset(x: offset ? 40.0 : 0.0)
				Spacer()
				if let isPopupOpen = isPopupOpen {
					Button("Custom Close Button") {
						isPopupOpen.wrappedValue = false
					}.foregroundColor(Color(.label))
				} else {
					Text("Center")
				}
				Spacer()
				Text("Bottom")
			}.frame(minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					maxHeight: .infinity,
					alignment: .top)
			if includeLink {
				NavigationLink("Next ▸", destination: SafeAreaDemoView(colorSeed: colorSeed, colorIndex: colorIndex + 1, includeLink: includeLink, onDismiss: onDismiss).navigationTitle("LNPopupUI"))
					.padding()
			}
		}
		.padding(4)
		.background(Color(UIColor.adaptiveColor(withSeed: "\(colorSeed)\(colorIndex > 0 ? String(colorIndex) : "")")).edgesIgnoringSafeArea(.all))
		.font(.system(.headline))
		.ifLet(onDismiss) { view, onDismiss in
			view.navigationBarItems(trailing: Button("Gallery") {
				onDismiss()
			})
		}
	}
}

//return view

extension View {
	func popupDemo(demoContent: DemoContent, isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>, includeContextMenu: Bool = false) -> some View {
		return self.popup(isBarPresented: isBarPresented, isPopupOpen: isPopupOpen, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			SafeAreaDemoView(colorSeed: "Popup", offset: true, isPopupOpen: isPopupOpen)
				.popupTitle(demoContent.title, subtitle: demoContent.subtitle)
				.popupImage(Image("genre\(demoContent.imageNumber)"))
				.popupProgress(0.5)
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
		.popupBarStyle(LNPopupBarStyle(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsBarStyle))!)
		.popupInteractionStyle(LNPopupInteractionStyle(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsInteractionStyle))!)
		.popupBarProgressViewStyle(LNPopupBarProgressViewStyle(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsProgressViewStyle))!)
		.popupCloseButtonStyle(LNPopupCloseButtonStyle(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsCloseButtonStyle))!)
		.if(UserDefaults.standard.object(forKey: PopupSettingsMarqueeStyle) != nil) { view in
			view.popupBarMarqueeScrollEnabled(UserDefaults.standard.bool(forKey: PopupSettingsMarqueeStyle))
		}
		.if(UserDefaults.standard.object(forKey: PopupSettingsVisualEffectViewBlurEffect) != nil) { view in
			view.popupBarBackgroundStyle(UIBlurEffect.Style(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsVisualEffectViewBlurEffect)))
		}
		.popupBarShouldExtendPopupBarUnderSafeArea(UserDefaults.standard.bool(forKey: PopupSettingsExtendBar))
		.if(includeContextMenu) { view in
			view.popupBarContextMenu {
				Button(action: {
					print("Context Menu Item 1")
				}) {
					Text("Context Menu Item 1")
					Image(systemName: "globe")
				}
				
				Button(action: {
					print("Context Menu Item 2")
				}) {
					Text("Context Menu Item 2")
					Image(systemName: "location.circle")
				}
			}
		}
	}
}
