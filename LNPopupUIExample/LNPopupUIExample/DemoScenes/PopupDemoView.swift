//
//  PopupDemoView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNPopupUI
import LNPopupController
import LoremIpsum
import SwiftUIIntrospect

extension NSParagraphStyle: @retroactive @unchecked Sendable {}

struct DemoContent {
	let title = LocalizedStringKey(LoremIpsum.title)
	let subtitle = LocalizedStringKey(LoremIpsum.sentence)
	let imageNumber = Int.random(in: 1..<31)
}

struct DemoToolbarModifier: ViewModifier {
	let presentBarHandler: (() -> Void)?
	let appearanceHandler: (() -> Void)?
	let hideBarHandler: (() -> Void)?
	
	@Environment(\.colorScheme) var colorScheme
	
	func body(content: Content) -> some View {
		content
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Button {
						presentBarHandler?()
					} label: {
						if presentBarHandler != nil  {
							Label("Present Bar", systemImage: "dock.arrow.up.rectangle")
						} else {
							Label("Test 1", systemImage: "1.square")
						}
					}
					Button {
						hideBarHandler?()
					} label: {
						if hideBarHandler != nil  {
							Label("Dismiss Bar", systemImage: "dock.arrow.down.rectangle")
						} else {
							Label("Test 2", systemImage: "2.square")
						}
					}
					Spacer()
					Button {
						appearanceHandler?()
					} label: {
						if hideBarHandler != nil  {
							Label {
								Text("Appearance")
							} icon: {
								//🤦‍♂️
								if colorScheme == .light {
									Image(uiImage: UIImage(_systemName: "appearance"))
										.renderingMode(.template)
								} else {
									Image(uiImage: UIImage(_systemName: "appearance"))
										.renderingMode(.template)
								}
							}
						} else {
							Label("Test 3", systemImage: "3.square")
						}
					}
				}
			}
	}
}

extension View {
	func demoToolbar(presentBarHandler: (() -> Void)? = nil, appearanceHandler: (() -> Void)? = nil, hideBarHandler: (() -> Void)? = nil) -> some View {
		modifier(DemoToolbarModifier(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler))
	}
}

struct ToolbarCloseButton: View {
	let action: @MainActor () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Label("Gallery", systemImage: "checkmark")
				.labelStyle(.toolbarDone)
		}
	}
}

#if compiler(>=6.2)
@available(iOS 26.0, *)
struct _CloseButton: UIViewRepresentable {
	let action: @MainActor () -> Void
	
	func makeUIView(context: Context) -> UIButton {
		var config = UIButton.Configuration.prominentGlass()
		config.imageColorTransformer = UIConfigurationColorTransformer { _ in
				.white.withAlphaComponent(0.75)
		}
		config.image = UIImage(systemName: "checkmark")
		config.preferredSymbolConfigurationForImage = .init(pointSize: 17)
		let button = UIButton(configuration: config, primaryAction: UIAction(handler: { _ in
			action()
		}))
		return button
	}
	
	func updateUIView(_ uiView: UIButton, context: Context) {
	}
}
#endif

struct CloseButton: View {
	let action: @MainActor () -> Void
	
	var body: some View {
#if compiler(>=6.2)
		if #available(iOS 26.0, *), LNPopupSettingsHasOS26Glass() {
			_CloseButton(action: action).frame(width: 46, height: 46)
		} else {
			ToolbarCloseButton(action: action)
		}
#else
		ToolbarCloseButton(action: action)
#endif
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
					ToolbarCloseButton {
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
	
	@AppStorage(.disableDemoSceneColors, store: .settings) var disableDemoSceneColors: Bool = false
	
	func body(content: Content) -> some View {
		if disableDemoSceneColors {
			content.background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
		} else {
			content.background(Color(UIColor.adaptiveColor(withSeed: "\(colorSeed)\(colorIndex > 0 ? String(colorIndex) : "")")).edgesIgnoringSafeArea(.all))
		}
	}
}

struct HideShowTabBarModifier: ViewModifier {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
	@Binding var bottomBarHideSupport: SafeAreaDemoView.BottomBarHideSupport?
	
	@ViewBuilder func body(content: Content) -> some View {
		if #available(iOS 18.0, *), bottomBarHideSupport?.showsBottomBarHideButton ?? false {
			content.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						withAnimation {
							bottomBarHideSupport?.isBottomBarPresented.toggle()
						}
					} label: {
						if UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular && bottomBarHideSupport?.isBottomBarTab ?? false {
							Image(systemName: "rectangle.topthird.inset.filled")
						} else {
							Image(systemName: "rectangle.bottomthird.inset.filled")
						}
					}
				}
			}
		} else {
			content
		}
	}
}

struct TrailingImageLabelStyle: LabelStyle {
	func makeBody(configuration: Configuration) -> some View {
		HStack {
			configuration.title
			configuration.icon
		}
	}
}

struct SafeAreaDemoView : View {
	struct BottomButtonHandlers {
		var presentBarHandler: (() -> Void)? = nil
		var appearanceHandler: (() -> Void)? = nil
		var hideBarHandler: (() -> Void)? = nil
	}
	
	struct BottomBarHideSupport {
		var showsBottomBarHideButton: Bool = false
		var isBottomBarTab: Bool? = false
		var isBottomBarPresented: Bool = true
	}
	
	let demoContent: DemoContent?
	
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
	
	@State var bottomBarHideSupport: BottomBarHideSupport?
	
	@AppStorage(.transitionType, store: .settings) var transitionType: Int = 0
	@AppStorage(.enableCustomizations, store: .settings) var enableCustomizations: Bool = false
	@AppStorage(.hidesBottomBarWhenPushed, store: .settings) var hidesBottomBarWhenPushed: Bool = true
	
	init(demoContent: DemoContent? = nil, colorSeed: String = "nil", colorIndex: Int = 0, includeToolbar: Bool = false, includeLink: Bool = false, offset: Bool = false, isPopupOpen: Binding<Bool>? = nil, bottomButtonsHandlers: BottomButtonHandlers? = nil, showDismissButton: Bool? = nil, onDismiss: (() -> Void)? = nil, bottomBarHideSupport: BottomBarHideSupport? = nil) {
		self.demoContent = demoContent
		
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
		
		self.presentBarHandler = bottomButtonsHandlers?.presentBarHandler
		self.appearanceHandler = bottomButtonsHandlers?.appearanceHandler
		self.hideBarHandler = bottomButtonsHandlers?.hideBarHandler
		
		_bottomBarHideSupport = State(initialValue: bottomBarHideSupport)
	}
	
	var body: some View {
		VStack(alignment: .center) {
			if let demoContent, transitionType == 0 {
				Image("genre\(demoContent.imageNumber)")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(maxWidth: 400)
					.clipShape(RoundedRectangle(cornerRadius: enableCustomizations ? 100 : 30, style: .continuous))
					.shadow(color: enableCustomizations ? .indigo : .black.opacity(0.33333), radius: 20)
					.padding([.leading, .trailing], 20)
					.padding([.top], 70)
					.popupTransitionTarget()
				Spacer()
			} else if demoContent != nil, transitionType == 2 {
				Image("genre17-expanded")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.ignoresSafeArea(.all)
					.popupTransitionTarget()
			} else {
				VStack {
					LNPopupText("Top").offset(x: offset ? 60.0 : 0.0)
					Spacer()
					LNPopupText("Bottom")
				}
				.frame(maxWidth: .infinity,
					   maxHeight: .infinity,
					   alignment: .center)
				.overlay {
					ZStack {
						if let isPopupOpen = isPopupOpen {
							Button {
								isPopupOpen.wrappedValue = false
							} label: {
								LNPopupText("Custom Close Button")
							}.foregroundColor(Color(.label))
						} else {
							if let presentBarHandler = presentBarHandler, let hideBarHandler = hideBarHandler {
								HStack(spacing: 2) {
									Button {
										presentBarHandler()
									} label: {
										Image(systemName: "dock.arrow.up.rectangle")
									}.padding(7).hoverEffect()
									Button {
										hideBarHandler()
									} label: {
										Image(systemName: "dock.arrow.down.rectangle")
									}.padding(7).hoverEffect()
								}.font(.title2).fontWeight(nil)
							} else {
								LNPopupText("Center")
							}
						}
						if includeLink {
							HStack {
								Spacer()
								
								NavigationLink {
									let bottomButtonsHandlers = BottomButtonHandlers(presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler)
									
									SafeAreaDemoView(colorSeed: colorSeed, colorIndex: colorIndex + 1, includeToolbar: hidesBottomBarWhenPushed ? false : includeToolbar, includeLink: includeLink, bottomButtonsHandlers: bottomButtonsHandlers, showDismissButton: true, onDismiss: onDismiss, bottomBarHideSupport: nil )
										.navigationTitle("LNPopupUI")
								} label: {
									Label {
										LNPopupText("Next")
									} icon: {
										Image(systemName: "arrowtriangle.forward.fill").font(.system(size: 8))
									}.labelStyle(TrailingImageLabelStyle())
								}.padding(7 ).hoverEffect()
							}
						}
					}
					.frame(maxWidth: .infinity,
						   maxHeight: .infinity,
						   alignment: .center)
					.edgesIgnoringSafeArea([.top, .bottom])
					.fontWeight(.semibold)
					.tint(Color(uiColor: .label))
					.modifier(HideShowTabBarModifier(bottomBarHideSupport: $bottomBarHideSupport))
					.toolbar(includeToolbar && bottomBarHideSupport?.isBottomBarPresented ?? true ? .visible : .hidden, for: .bottomBar)
					.toolbar(bottomBarHideSupport?.isBottomBarPresented ?? true ? .visible : .hidden, for: .tabBar)
					.introspect(.viewController, on: .iOS(.v16, .v17, .v18)) { vc in
						vc.navigationItem.backButtonTitle = String(localized: "Back")
					}
				}
			}
		}
		.frame(maxWidth: .infinity,
			   maxHeight: .infinity,
			   alignment: .center)
		.modifier(BackgroundViewColorModifier(colorSeed: colorSeed, colorIndex: colorIndex))
		.fontWeight(.semibold)
		.modifier(ToolbarModifier(includeToolbar: includeToolbar, presentBarHandler: presentBarHandler, appearanceHandler: appearanceHandler, hideBarHandler: hideBarHandler))
		.modifier(ShowDismissModifier(showDismissButton: showDismissButton, onDismiss: onDismiss))
	}
}

fileprivate let customizationParagraphStyle: NSParagraphStyle = {
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.alignment = .right
	paragraphStyle.lineBreakMode = .byTruncatingTail
	return paragraphStyle
}()

struct HapticFeedbackModifier: ViewModifier {
	@AppStorage(.hapticFeedbackEnabled, store: .settings) var hapticFeedbackEnabled: Bool = true

	@ViewBuilder func body(content: Content) -> some View {
		content.popupHapticFeedbackEnabled(hapticFeedbackEnabled)
	}
}

struct LimitFloatingContentWidthModifier: ViewModifier {
	@AppStorage(.limitFloatingWidth, store: .settings) var limitFloatingWidth: Bool = true
	
	@ViewBuilder func body(content: Content) -> some View {
		content.popupBarLimitFloatingContentWidth(limitFloatingWidth)
	}
}

struct MarqueeModifier: ViewModifier {
	@AppStorage(.marqueeEnabled, store: .settings) var marqueeEnabled: Bool = false
	@AppStorage(.marqueeCoordinationEnabled, store: .settings) var marqueeCoordinationEnabled: Bool = true
	
	@ViewBuilder func body(content: Content) -> some View {
		content.popupBarMarqueeScrollEnabled(marqueeEnabled, coordinateAnimations: marqueeCoordinationEnabled)
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
				.popupBarFloatingBackgroundShadow(color: .red, radius: 8, x: 0, y: 0)
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
					if [.floating, .floatingCompact].contains(popupBar.effectiveBarStyle) {
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
				ForEach(["♥️ - Hearts", "♣️ - Clubs", "♠️ - Spades", "♦️ - Diamonds"], id: \.self) { str in
					Button {
						print(str)
					} label: {
						LNPopupText(str)
					}
				}
			}
		} else {
			content
		}
	}
}

struct CustomTextLabelsModifier: ViewModifier {
	@AppStorage(.enableCustomLabels, store: .settings) var enableCustomLabels: Bool = false
	let demoContent: DemoContent
	
	func body(content: Content) -> some View {
		if enableCustomLabels {
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
	
	@AppStorage(.barStyle, store: .settings) var barStyle: LNPopupBar.Style = .default
	@AppStorage(.shineEnabled, store: .settings) var shineEnabled: Bool = false
	@AppStorage(.interactionStyle, store: .settings) var interactionStyle: UIViewController.__PopupInteractionStyle = .default
	@AppStorage(.closeButtonStyle, store: .settings) var _closeButtonStyle: LNPopupCloseButton.Style = .default
	@AppStorage(.closeButtonPositioning, store: .settings) var closeButtonPositioning: LNPopupCloseButton.Positioning = .default
	@AppStorage(.progressViewStyle, store: .settings) var progressViewStyle: LNPopupBar.ProgressViewStyle = .default
	@AppStorage(.visualEffectViewBlurEffect, store: .settings) var blurEffectStyle: UIBlurEffect.Style = .default
	
	@AppStorage(.extendBar, store: .settings) var extendBar: Bool = true
	@AppStorage(.customBarEverywhereEnabled, store: .settings) var customPopupBar: Bool = false
	@AppStorage(.enableCustomizations, store: .settings) var enableCustomizations: Bool = false
	@AppStorage(.contextMenuEnabled, store: .settings) var contextMenu: Bool = false
	
	@AppStorage(.transitionType, store: .settings) var transitionType: Int = 0
	
	var closeButtonStyle: LNPopupCloseButton.Style {
		_closeButtonStyle == .default && LNPopupSettingsHasOS26Glass() ? .shinyGlass : _closeButtonStyle
	}
	
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
			SafeAreaDemoView(demoContent: demoContent, colorSeed: "Popup", offset: [.grabber, .chevron].contains(closeButtonStyle), isPopupOpen: isPopupOpen)
				.modifier(CustomTextLabelsModifier(demoContent: demoContent))
				.popupImage(Image(transitionType == 2 ? "genre17" : "genre\(demoContent.imageNumber)"))
				.popupProgress(0.5)
				.popupBarItems {
					ToolbarItemGroup(placement: .popupBar) {
						Button {
							print("Play")
						} label: {
							Image(systemName: "play.fill")
						}
						.frame(minWidth: 30)
						.modifier(CustomizationsTintModifier(enableCustomizations: enableCustomizations))
					}
				} trailing: {
					ToolbarItemGroup(placement: .popupBar) {
						Button {
							print("Next")
						} label: {
							Image(systemName: "forward.fill")
						}
						.frame(minWidth: 30)
						.modifier(CustomizationsTintModifier(enableCustomizations: enableCustomizations))
					}
				}
			
		}
		.popupBarStyle(barStyle)
		.popupBarShineEnabled(shineEnabled)
		.popupInteractionStyle(popupInteractionStyleFromAppStorage(interactionStyle))
		.popupBarProgressViewStyle(progressViewStyle)
		.popupCloseButtonStyle(closeButtonStyle)
		.popupCloseButtonPositioning(closeButtonPositioning)
		.modifier(MarqueeModifier())
		.modifier(HapticFeedbackModifier())
		.modifier(LimitFloatingContentWidthModifier())
		.modifier(FloatingBackgroundEffectModifier(blurEffectStyle: blurEffectStyle, barStyle: barStyle))
		.modifier(BackgroundEffectModifier(blurEffectStyle: blurEffectStyle, barStyle: barStyle))
		.modifier(CustomBarModifier(customPopupBar: customPopupBar))
		.modifier(CustomizationsModifier(enableCustomizations: enableCustomizations))
		.popupBarShouldExtendPopupBarUnderSafeArea(extendBar)
		.modifier(ContextMenuModifier(includeContextMenu: includeContextMenu))
	}
}

extension View {
	func popupDemo(demoContent: DemoContent, isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, includeContextMenu: Bool) -> some View {
		return self.modifier(PopupDemoViewModifier(demoContent: demoContent, isBarPresented: isBarPresented, isPopupOpen: isPopupOpen, includeContextMenu: includeContextMenu))
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
	@AppStorage(.barStyle, store: .settings) var barStyle: LNPopupBar.Style = .default
	
	func body(content: Content) -> some View {
		content.introspect(.tabView, on: .iOS(.v16, .v17, .v18, .v26), scope: .ancestor) { tabBarController in
			guard !LNPopupSettingsHasOS26Glass() else {
				return
			}
			
			let isFloating = barStyle == .floating || barStyle == .floatingCompact || barStyle == .default && ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17
			tabBarController.tabBar.standardAppearance.backgroundEffect = UIBlurEffect(style: isFloating ? .systemThinMaterial : .systemChromeMaterial)
		}.introspect(.navigationStack, on: .iOS(.v16, .v17, .v18, .v26), scope: .ancestor) { navBarController in
			guard !LNPopupSettingsHasOS26Glass() else {
				return
			}
			
			let isFloating = barStyle == .floating || barStyle == .floatingCompact || barStyle == .default && ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17
			let effect = UIBlurEffect(style: isFloating ? .systemThinMaterial : .systemChromeMaterial)
			navBarController.navigationBar.standardAppearance.backgroundEffect = effect
			navBarController.navigationBar.compactAppearance?.backgroundEffect = effect
			navBarController.toolbar.standardAppearance.backgroundEffect = effect
			navBarController.toolbar.compactAppearance?.backgroundEffect = effect
		}
	}
}

extension View {
	func fixBottomBarAppearance() -> some View {
		return modifier(FixBottomBarAppearanceModifier())
	}
}

struct MaterialTabView<Content: View>: View {
	let tabView: any View
	
	init(@ViewBuilder content: () -> Content) {
		tabView = TabView {
			content().fixBottomBarAppearance()
		}
	}
	
	@available(iOS 18.0, *)
	init<C>(@TabContentBuilder<Never> content: () -> C) where Content == TabContentBuilder<Never>.Content<C>, C : TabContent {
		tabView = TabView.init(content: content)
	}
	
	var body: some View {
		AnyView(tabView)
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

@MainActor
struct LNPopupText: View {
	let text: Text
	public init(_ content: String) {
		@AppStorage(PopupSetting.forceRTL) var forceRTL: Bool = false
		
		if forceRTL == false {
			text = Text(LocalizedStringKey(content))
		} else {
			text = Text(Bundle.main.localizedString(forKey: content, value: nil, table: nil))
		}
	}
	
	var body: some View {
		text
	}
}
