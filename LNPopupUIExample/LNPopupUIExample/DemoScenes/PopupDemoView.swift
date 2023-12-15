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

extension NSParagraphStyle: @unchecked Sendable {}

struct DemoContent {
	let title = LocalizedStringKey(LoremIpsum.title)
	let subtitle = LocalizedStringKey(LoremIpsum.sentence)
	let imageNumber = Int.random(in: 1..<31)
}

extension View {
	func demoToolbar(presentBarHandler: (() -> Void)? = nil, appearanceHandler: (() -> Void)? = nil, hideBarHandler: (() -> Void)? = nil) -> some View {
		return toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Button("Present Bar") {
					presentBarHandler?()
				}
				Spacer()
				Button("Appearance") {
					appearanceHandler?()
				}
				Spacer()
				Button("Dismiss Bar") {
					hideBarHandler?()
				}
			}
		}
	}
}

struct ToolbarModifier: ViewModifier {
	let includeToolbar: Bool
	let presentBarHandler: (() -> Void)?
	let appearanceHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?
	
	@ViewBuilder func body(content: Content) -> some View {
		if includeToolbar {
			content.demoToolbar(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler)
		} else {
			content
		}
	}
}

struct ShowDismissModifier: ViewModifier {
	let showDismissButton: Bool
	let onDismiss: (() -> Void)?
	
	@ViewBuilder func body(content: Content) -> some View {
		if showDismissButton {
			content.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Gallery") {
						onDismiss?()
					}
				}
			}
		} else {
			content
		}
	}
}

struct BackgroundViewColorModifier: ViewModifier {
	let colorSeed: String
	let colorIndex: Int
	
	@AppStorage(DemoAppDisableDemoSceneColors, store: .settings) var disableDemoSceneColors: Bool = false
	
	func body(content: Content) -> some View {
		if disableDemoSceneColors {
			content.background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
		} else {
			content.background(Color(UIColor.adaptiveColor(withSeed: "\(colorSeed)\(colorIndex > 0 ? String(colorIndex) : "")")).edgesIgnoringSafeArea(.all))
		}
	}
}

struct SafeAreaDemoView : View {
	let includeLink: Bool
	let includeToolbar: Bool
	let offset: Bool
	let isPopupOpen: Binding<Bool>?
	
	let showDismissButton: Bool
	let onDismiss: (() -> Void)?
	
	let colorSeed: String
	let colorIndex: Int
	
	let presentBarHandler: (() -> Void)?
	let appearanceHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?
	
	init(colorSeed: String = "nil", colorIndex: Int = 0, includeToolbar: Bool = false, includeLink: Bool = false, offset: Bool = false, isPopupOpen: Binding<Bool>? = nil, presentBarHandler: (() -> Void)? = nil, appearanceHandler: (() -> Void)? = nil, hideBarHandler: (() -> Void)? = nil, showDismissButton: Bool? = nil, onDismiss: (() -> Void)? = nil) {
		self.includeLink = includeLink
		self.includeToolbar = includeToolbar
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
		
		self.presentBarHandler = presentBarHandler
		self.appearanceHandler = appearanceHandler
		self.hideBarHandler = hideBarHandler
	}
	
	var body: some View {
		VStack(alignment: .center) {
			Text("Top").offset(x: offset ? 40.0 : 0.0)
			Spacer()
			Text("Bottom")
		}
		.frame(maxWidth: .infinity,
			   maxHeight: .infinity,
			   alignment: .center)
		.modifier(BackgroundViewColorModifier(colorSeed: colorSeed, colorIndex: colorIndex))
		.fontWeight(.semibold)
		.modifier(ToolbarModifier(includeToolbar: includeToolbar, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler))
		.modifier(ShowDismissModifier(showDismissButton: showDismissButton, onDismiss: onDismiss))
		.overlay {
			ZStack {
				if let isPopupOpen = isPopupOpen {
					Button("Custom Close Button") {
						isPopupOpen.wrappedValue = false
					}.foregroundColor(Color(.label))
				} else {
					if let presentBarHandler = presentBarHandler, let hideBarHandler = hideBarHandler {
						HStack(spacing: 16) {
							Button {
								presentBarHandler()
							} label: {
								Image(systemName: "dock.arrow.up.rectangle")
							}
							Button {
								hideBarHandler()
							} label: {
								Image(systemName: "dock.arrow.down.rectangle")
							}
						}.font(.title2).fontWeight(nil)
					} else {
						Text("Center")
					}
				}
				if includeLink {
					HStack {
						Spacer()
						NavigationLink("Next ▸", destination: SafeAreaDemoView(colorSeed: colorSeed, colorIndex: colorIndex + 1, includeToolbar: includeToolbar, includeLink: includeLink, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler, showDismissButton: true, onDismiss: onDismiss)
							.navigationTitle("LNPopupUI"))
						.padding()
					}
				}
			}
			.frame(maxWidth: .infinity,
				   maxHeight: .infinity,
				   alignment: .center)
			.edgesIgnoringSafeArea([.top, .bottom])
			.fontWeight(.semibold)
			.tint(Color(uiColor: .label))
		}
	}
}

fileprivate var customizationParagraphStyle: NSParagraphStyle = {
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.alignment = .right
	paragraphStyle.lineBreakMode = .byTruncatingTail
	return paragraphStyle
}()

struct HapticFeedbackModifier: ViewModifier {
	let hapticFeedbackStyle: Int

	@ViewBuilder func body(content: Content) -> some View {
		if hapticFeedbackStyle == 0 {
			content
		} else {
			content.popupHapticFeedbackEnabled(hapticFeedbackStyle == 2)
		}
	}
}

struct MarqueeModifier: ViewModifier {
	let marqueeStyle: Int
	
	@ViewBuilder func body(content: Content) -> some View {
		if marqueeStyle == 0 {
			content
		} else {
			content.popupBarMarqueeScrollEnabled(marqueeStyle == 2)
		}
	}
}

struct FloatingBackgroundEffectModifier: ViewModifier {
	let blurEffectStyle: UIBlurEffect.Style
	let barStyle: LNPopupBar.Style
	
	@ViewBuilder func body(content: Content) -> some View {
		if blurEffectStyle != .default && (barStyle == .floating || barStyle == .default && ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17) {
			content.popupBarFloatingBackgroundEffect(UIBlurEffect(style: blurEffectStyle))
		} else {
			content
		}
	}
}

struct BackgroundEffectModifier: ViewModifier {
	let blurEffectStyle: UIBlurEffect.Style
	let barStyle: LNPopupBar.Style
	
	@ViewBuilder func body(content: Content) -> some View {
		if blurEffectStyle != .default && (barStyle != .floating) && (barStyle != .default || ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 17) {
			content
				.popupBarInheritsAppearanceFromDockingView(false)
				.popupBarBackgroundEffect(UIBlurEffect(style: blurEffectStyle))
		} else {
			content
		}
	}
}

struct CustomBarModifier: ViewModifier {
	let customPopupBar: Bool
	
	@ViewBuilder func body(content: Content) -> some View {
		if customPopupBar == false {
			content
		} else {
			content.popupBarCustomView(wantsDefaultTapGesture: true, wantsDefaultPanGesture: true, wantsDefaultHighlightGesture: true) {
				ZStack(alignment: .trailing) {
					HStack {
						Spacer()
						Button("Test") {
							print("Yay")
						}.padding()
						Spacer()
						
					}
				}
			}
		}
	}
}

struct CustomizationsModifier: ViewModifier {
	let enableCustomizations: Bool
	
	@ViewBuilder func body(content: Content) -> some View {
		if enableCustomizations {
			content
				.popupBarFloatingBackgroundShadow(color: .red, radius: 8)
				.popupBarImageShadow(color: .yellow, radius: 5)
				.popupBarTitleTextAttributes(AttributeContainer()
					.font(Font.custom("Chalkduster", size: 14, relativeTo: .headline))
					.foregroundColor(.yellow)
					.paragraphStyle(customizationParagraphStyle))
				.popupBarSubtitleTextAttributes(AttributeContainer()
					.font(.custom("Chalkduster", size: 12, relativeTo: .subheadline))
					.foregroundColor(.green)
					.paragraphStyle(customizationParagraphStyle))
				.popupBarCustomizer { popupBar in
					if popupBar.effectiveBarStyle == .floating {
						popupBar.inheritsAppearanceFromDockingView = true
						popupBar.standardAppearance.floatingBackgroundEffect = UIBlurEffect(style: .dark)
					} else {
						popupBar.inheritsAppearanceFromDockingView = false
						popupBar.standardAppearance.backgroundEffect = UIBlurEffect(style: .dark)
					}
				}
		} else {
			content
		}
	}
}

struct CustomizationsTintModifier: ViewModifier {
	let enableCustomizations: Bool
	
	@ViewBuilder func body(content: Content) -> some View {
		if enableCustomizations {
			content.accentColor(.yellow)
		} else {
			content
		}
	}
}

struct ContextMenuModifier: ViewModifier {
	let includeContextMenu: Bool
	
	func body(content: Content) -> some View {
		if includeContextMenu {
			content.popupBarContextMenu {
				Button("♥️ - Hearts", action: { print ("♥️ - Hearts") })
				Button("♣️ - Clubs", action: { print ("♣️ - Clubs") })
				Button("♠️ - Spades", action: { print ("♠️ - Spades") })
				Button("♦️ - Diamonds", action: { print ("♦️ - Diamonds") })
			}
		} else {
			content
		}
	}
}

struct CustomTextLabelsModifier: ViewModifier {
	let includeCustomTextLabels: Bool
	let demoContent: DemoContent
	
	func body(content: Content) -> some View {
		if includeCustomTextLabels {
			content.popupTitle {
				Text(demoContent.title).foregroundColor(.orange).fontWeight(.black)
			} subtitle: {
				Text(demoContent.subtitle).foregroundColor(.blue).fontWeight(.medium)
			}
		} else {
			content.popupTitle(demoContent.title, subtitle: demoContent.subtitle)
		}
	}
}

struct PopupDemoViewModifier: ViewModifier {
	let demoContent: DemoContent
	let isBarPresented: Binding<Bool>
	let isPopupOpen: Binding<Bool>?
	let includeContextMenu: Bool
	let includeCustomTextLabels: Bool
	
	@AppStorage(PopupSettingsBarStyle, store: .settings) var barStyle: LNPopupBar.Style = .default
	@AppStorage(PopupSettingsInteractionStyle, store: .settings) var interactionStyle: UIViewController.__PopupInteractionStyle = .default
	@AppStorage(PopupSettingsCloseButtonStyle, store: .settings) var closeButtonStyle: LNPopupCloseButton.Style = .default
	@AppStorage(PopupSettingsProgressViewStyle, store: .settings) var progressViewStyle: LNPopupBar.ProgressViewStyle = .default
	@AppStorage(PopupSettingsMarqueeStyle, store: .settings) var marqueeStyle: Int = 0
	@AppStorage(PopupSettingsHapticFeedbackStyle, store: .settings) var hapticFeedbackStyle: Int = 0
	@AppStorage(PopupSettingsVisualEffectViewBlurEffect, store: .settings) var blurEffectStyle: UIBlurEffect.Style = .default
	
	@AppStorage(PopupSettingsExtendBar, store: .settings) var extendBar: Bool = true
	@AppStorage(PopupSettingsCustomBarEverywhereEnabled, store: .settings) var customPopupBar: Bool = false
	@AppStorage(PopupSettingsEnableCustomizations, store: .settings) var enableCustomizations: Bool = false
	@AppStorage(PopupSettingsContextMenuEnabled, store: .settings) var contextMenu: Bool = false
	
	fileprivate func popupInteractionStyleFromAppStorage(_ style: UIViewController.__PopupInteractionStyle) -> UIViewController.PopupInteractionStyle {
		switch style.rawValue {
		case 1:
			return .drag
		case 2:
			return .snap
		case 3:
			return .scroll
		case 0xFFFF:
			return .none
		default:
			return .default
		}
	}
	
	func body(content: Content) -> some View {
		content.popup(isBarPresented: isBarPresented, isPopupOpen: isPopupOpen, onOpen: {
			print("Opened")
		}, onClose: {
			print("Closed")
		}) {
			SafeAreaDemoView(colorSeed: "Popup", offset: true, isPopupOpen: isPopupOpen)
				.modifier(CustomTextLabelsModifier(includeCustomTextLabels: includeCustomTextLabels, demoContent: demoContent))
				.popupImage(Image("genre\(demoContent.imageNumber)"))
				.popupProgress(0.5)
				.popupBarItems {
					ToolbarItemGroup(placement: .popupBar) {
						Button(action: {
							print("Play")
						}) {
							Image(systemName: "play.fill")
						}.modifier(CustomizationsTintModifier(enableCustomizations: enableCustomizations))
					}
				} trailing: {
					ToolbarItemGroup(placement: .popupBar) {
						Button(action: {
							print("Next")
						}) {
							Image(systemName: "forward.fill")
						}.modifier(CustomizationsTintModifier(enableCustomizations: enableCustomizations))
					}
				}
			
		}
		.popupBarStyle(barStyle)
		.popupInteractionStyle(popupInteractionStyleFromAppStorage(interactionStyle))
		.popupBarProgressViewStyle(progressViewStyle)
		.popupCloseButtonStyle(closeButtonStyle)
		.modifier(MarqueeModifier(marqueeStyle: marqueeStyle))
		.modifier(HapticFeedbackModifier(hapticFeedbackStyle: hapticFeedbackStyle))
		.modifier(FloatingBackgroundEffectModifier(blurEffectStyle: blurEffectStyle, barStyle: barStyle))
		.modifier(BackgroundEffectModifier(blurEffectStyle: blurEffectStyle, barStyle: barStyle))
		.modifier(CustomBarModifier(customPopupBar: customPopupBar))
		.modifier(CustomizationsModifier(enableCustomizations: enableCustomizations))
		.popupBarShouldExtendPopupBarUnderSafeArea(extendBar)
		.modifier(ContextMenuModifier(includeContextMenu: includeContextMenu))
	}
}

extension View {
	func popupDemo(demoContent: DemoContent, isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, includeContextMenu: Bool, includeCustomTextLabels: Bool = false) -> some View {
		return self.modifier(PopupDemoViewModifier(demoContent: demoContent, isBarPresented: isBarPresented, isPopupOpen: isPopupOpen, includeContextMenu: includeContextMenu, includeCustomTextLabels: includeCustomTextLabels))
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

fileprivate struct FixBottomBarAppearanceModifier: ViewModifier {
	@AppStorage(PopupSettingsBarStyle, store: .settings) var barStyle: LNPopupBar.Style = .default
	
	func body(content: Content) -> some View {
		content.toolbarBackground(barStyle == .floating || barStyle == .default && ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17 ? Material.thin : Material.bar, for: .tabBar, .bottomBar, .navigationBar)
//		content.toolbarBackground(.red, for: .tabBar, .bottomBar, .navigationBar)
	}
}

fileprivate extension View {
	func fixBottomBarAppearance() -> some View {
		return modifier(FixBottomBarAppearanceModifier())
	}
}

struct MaterialTabView<Content: View>: View {
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		TabView {
			content.fixBottomBarAppearance()
		}
	}
}

struct MaterialNavigationStack<Content: View>: View {
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		NavigationStack {
			content.fixBottomBarAppearance()
		}
	}
}

@available(iOS 17.0, *)
struct MaterialNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {
	let sidebar: Sidebar
	let content: Content
	let detail: Detail
	let columnVisibility: Binding<NavigationSplitViewVisibility>
	let preferredCompactColumn: Binding<NavigationSplitViewColumn>
	
	public init(columnVisibility: Binding<NavigationSplitViewVisibility>, preferredCompactColumn: Binding<NavigationSplitViewColumn>, @ViewBuilder sidebar: () -> Sidebar, @ViewBuilder content: () -> Content, @ViewBuilder detail: () -> Detail) {
		self.sidebar = sidebar()
		self.content = content()
		self.detail = detail()
		self.columnVisibility = columnVisibility
		self.preferredCompactColumn = preferredCompactColumn
	}
	
	var body: some View {
		NavigationSplitView(columnVisibility: columnVisibility, preferredCompactColumn: preferredCompactColumn) {
			sidebar.fixBottomBarAppearance()
		} content: {
			content.fixBottomBarAppearance()
		} detail: {
			detail.fixBottomBarAppearance()
		}
	}
}
