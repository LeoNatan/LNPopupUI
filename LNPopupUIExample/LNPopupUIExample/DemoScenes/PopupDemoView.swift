//
//  PopupDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LNPopupUI
import LNPopupController
import LoremIpsum

struct DemoContent {
	let title = LoremIpsum.title
	let subtitle = LoremIpsum.sentence
	let imageNumber = Int.random(in: 1..<31)
}

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
	
	@ViewBuilder
	func `if`<Transform: View, ElseTransform: View>(
		_ value: Bool,
		transform: (Self) -> Transform,
		`else` elseTransform: ((Self) -> ElseTransform)? = nil
	) -> some View {
		if value {
			transform(self)
		} else {
			if let elseTransform = elseTransform {
				elseTransform(self)
			} else {
				self
			}
		}
	}
}

extension View {
	func demoToolbar(presentBarHandler: (() -> Void)? = nil, appearanceHandler: (() -> Void)? = nil, hideBarHandler: (() -> Void)? = nil) -> some View {
		return toolbar {
			ToolbarItem(placement: .bottomBar) {
				Button("Present Bar") {
					presentBarHandler?()
				}
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button("Appearance") {
					appearanceHandler?()
				}
			}
			ToolbarItem(placement: .bottomBar) {
				Spacer()
			}
			ToolbarItem(placement: .bottomBar) {
				Button("Dismiss Bar") {
					hideBarHandler?()
				}
			}
		}
	}
}

struct SafeAreaDemoView : View {
	let includeLink: Bool
	let offset: Bool
	let isPopupOpen: Binding<Bool>?
	
	let showDismissButton: Bool
	let onDismiss: (() -> Void)?
	
	let colorSeed: String
	let colorIndex: Int
	
	let includeToolbar: Bool
	let presentBarHandler: (() -> Void)?
	let appearanceHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?
	
	init(colorSeed: String = "nil", colorIndex: Int = 0, includeLink: Bool = false, offset: Bool = false, isPopupOpen: Binding<Bool>? = nil, presentBarHandler: (() -> Void)? = nil, appearanceHandler: (() -> Void)? = nil, hideBarHandler: (() -> Void)? = nil, showDismissButton: Bool? = nil, onDismiss: (() -> Void)? = nil) {
		self.includeLink = includeLink
		self.offset = offset
		self.isPopupOpen = isPopupOpen
		
		self.onDismiss = onDismiss
		if let showDismissButton = showDismissButton, showDismissButton == true {
			self.showDismissButton = showDismissButton && onDismiss != nil
		} else {
			self.showDismissButton = false
		}
		
		self.colorSeed = colorSeed
		self.colorIndex = colorIndex
		
		includeToolbar = presentBarHandler != nil || appearanceHandler != nil || hideBarHandler != nil
		self.presentBarHandler = presentBarHandler
		self.appearanceHandler = appearanceHandler
		self.hideBarHandler = hideBarHandler
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
				NavigationLink("Next ▸", destination: SafeAreaDemoView(colorSeed: colorSeed, colorIndex: colorIndex + 1, includeLink: includeLink, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler, showDismissButton: true, onDismiss: onDismiss).navigationTitle("LNPopupUI"))
					.padding()
			}
		}
		.padding(4)
		.background(Color(UIColor.adaptiveColor(withSeed: "\(colorSeed)\(colorIndex > 0 ? String(colorIndex) : "")")).edgesIgnoringSafeArea(.all))
		.font(.system(.headline))
		.if(showDismissButton) { view in
			view.navigationBarItems(trailing: Button("Gallery") {
				onDismiss?()
			})
		}.if(includeToolbar) { view in
			view.demoToolbar(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler)
		}
	}
}

extension View {
	func popupDemo(demoContent: DemoContent, isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, includeContextMenu: Bool = false, includeCustomTextLabels: Bool = false) -> some View {
		return self.popup(isBarPresented: isBarPresented, isPopupOpen: isPopupOpen, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			SafeAreaDemoView(colorSeed: "Popup", offset: true, isPopupOpen: isPopupOpen)
				.if(includeCustomTextLabels) { view in
					view.popupTitle {
						Text(demoContent.title).foregroundColor(.pink).fontWeight(.heavy)
					} subtitle: {
						Text(demoContent.subtitle)
					}
				} else: { view in
					view.popupTitle(demoContent.title, subtitle: demoContent.subtitle)
				}
				.popupImage(Image("genre\(demoContent.imageNumber)"))
				.popupProgress(0.5)
				.popupBarItems({
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
			view.popupBarInheritsAppearanceFromDockingView(false)
				.popupBarBackgroundEffect(UIBlurEffect(style: UIBlurEffect.Style(rawValue: UserDefaults.standard.integer(forKey: PopupSettingsVisualEffectViewBlurEffect))!))
		}
		.if(UserDefaults.standard.bool(forKey: PopupSettingsEnableCustomizations)) { view in
			view.popupBarInheritsAppearanceFromDockingView(false)
				.popupBarCustomizer { popupBar in
					let paragraphStyle = NSMutableParagraphStyle()
					paragraphStyle.alignment = .right
					paragraphStyle.lineBreakMode = .byTruncatingTail
					
					popupBar.standardAppearance.backgroundEffect = UIBlurEffect(style: .dark)
					popupBar.standardAppearance.titleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFont(name: "Chalkduster", size: 14)!, .foregroundColor: UIColor.yellow ]
					popupBar.standardAppearance.titleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFont(name: "Chalkduster", size: 12)!, .foregroundColor: UIColor.green ]
					
					popupBar.tintColor = .yellow
				}
		}
		.popupBarShouldExtendPopupBarUnderSafeArea(UserDefaults.standard.bool(forKey: PopupSettingsExtendBar))
		.if(includeContextMenu) { view in
			view.popupBarContextMenu {
				Button("♥️ - Hearts", action: { print ("♥️ - Hearts") })
				Button("♣️ - Clubs", action: { print ("♣️ - Clubs") })
				Button("♠️ - Spades", action: { print ("♠️ - Spades") })
				Button("♦️ - Diamonds", action: { print ("♦️ - Diamonds") })
			}
		}
	}
}

struct SafeAreaDemoView_Previews: PreviewProvider {
	static var previews: some View {
		SafeAreaDemoView()
		SafeAreaDemoView(colorSeed: "offset", offset: true)
		SafeAreaDemoView(colorSeed: "includeLink", includeLink: true)
		SafeAreaDemoView(colorSeed: "colorIndex", colorIndex: 4)
	}
}
