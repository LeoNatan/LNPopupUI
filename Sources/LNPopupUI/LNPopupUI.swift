//
//  LNPopupUI.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNSwiftUIUtils
@_exported import LNPopupController

public extension ToolbarItemPlacement {
#if swift(>=6.0)
	@MainActor
#endif
	static let popupBar: ToolbarItemPlacement = .bottomBar
}

public extension View {
	
	/// Presents a popup bar with a popup content.
	///
	/// - Parameters:
	///   - isBarPresented: A binding to whether the popup bar is presented.
	///   - isPopupOpen: A binding to whether the popup is open. (optional)
	///   - onOpen: A closure executed when the popup opens. (optional)
	///   - onClose: A closure executed when the popup closes. (optional)
	///   - popupContent: A closure returning the content of the popup.
	func popup<PopupContent>(isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, @ViewBuilder popupContent: @escaping () -> PopupContent) -> some View where PopupContent : View {
		ZStack {
			//These two lines are to make sure the system rerenders if the isBarPresented and isPopupOpen bindings change.
			isBarPresented.wrappedValue ? EmptyView() : EmptyView()
			isPopupOpen?.wrappedValue ?? false  ? EmptyView() : EmptyView()
			LNPopupContainerViewWrapper(isBarPresented: isBarPresented, isOpen: isPopupOpen, onOpen: onOpen, onClose: onClose, popupContent: popupContent) {
				self
			}.edgesIgnoringSafeArea(.all)
		}
	}
	
	/// Presents a popup bar with a UIKit `UIViewController` as the popup content.
	///
	/// - Parameters:
	///   - isBarPresented: A binding to whether the popup bar is presented.
	///   - isPopupOpen: A binding to whether the popup is open. (optional)
	///   - onOpen: A closure executed when the popup opens. (optional)
	///   - onClose: A closure executed when the popup closes. (optional)
	///   - popupContentController: A UIKit view controller to use as the popup content controller.
	func popup(isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, popupContentController: UIViewController) -> some View {
		ZStack {
			//These two lines are to make sure the system rerenders if the isBarPresented and isPopupOpen bindings change.
			isBarPresented.wrappedValue ? EmptyView() : EmptyView()
			isPopupOpen?.wrappedValue ?? false  ? EmptyView() : EmptyView()
			LNPopupContainerViewWrapper(isBarPresented: isBarPresented, isOpen: isPopupOpen ?? Binding.constant(false), onOpen: onOpen, onClose: onClose, popupContentController: popupContentController) {
				self
			}.edgesIgnoringSafeArea(.all)
		}
	}
	
	/// Sets the popup interaction style.
	///
	/// - Parameter style: The popup interaction style.
	func popupInteractionStyle(_ style: UIViewController.PopupInteractionStyle) -> some View {
		environment(\.popupInteractionStyle, ^^style)
	}
	
	/// Sets the popup close button style.
	///
	/// - Parameter style: The popup close button style.
	func popupCloseButtonStyle(_ style: LNPopupCloseButton.Style) -> some View {
		environment(\.popupCloseButtonStyle, ^^style)
	}
	
	/// Gets or sets the positioning of the popup close button.
	///
	/// - Parameter positioning: The popup close button positioning
	func popupCloseButtonPositioning(_ positioning: LNPopupCloseButton.Positioning) -> some View {
		environment(\.popupCloseButtonPositioning, ^^positioning)
	}
	
	/// Sets the popup bar style.
	///
	/// Setting a custom popup bar view will methis this modifier have no effect.
	///
	/// - Parameter style: The popup bar style.
	func popupBarStyle(_ style: LNPopupBar.Style) -> some View {
		environment(\.popupBarStyle, ^^style)
	}
	
	/// Sets the popup bar's progress style.
	///
	/// - Parameter style: The popup bar's progress style.
	func popupBarProgressViewStyle(_ style: LNPopupBar.ProgressViewStyle) -> some View {
		environment(\.popupBarProgressViewStyle, ^^style)
	}
	
	/// Enables or disables the popup bar marquee scrolling. When enabled, titles and subtitles that are longer than the space available will scroll text over time.
	///
	/// - Parameters:
	///   - enabled: Marquee scroll enabled.
	///   - scrollRate: The scroll rate, in points, of the title and subtitle marquee animation.
	///   - delay: The delay, in seconds, before starting the title and subtitle marquee animation.
	///   - coordinateAnimations: Coordinate the title and subtitle marquee scroll animations.
	func popupBarMarqueeScrollEnabled(_ enabled: Bool? = true, scrollRate: CGFloat? = nil, delay: TimeInterval? = nil, coordinateAnimations: Bool? = nil) -> some View {
		environment(\.popupBarMarqueeScrollEnabled, ^^enabled).environment(\.popupBarMarqueeRate, ^^scrollRate).environment(\.popupBarMarqueeDelay, ^^delay).environment(\.popupBarCoordinateMarqueeAnimations, ^^coordinateAnimations)
	}
	
	/// Enables or disables outer shine on a floating popup bar.
	///
	/// Shine is only supported on iOS 26.0 and later.
	func popupBarShineEnabled(_ enabled: Bool? = true) -> some View {
		environment(\.popupBarShineEnabled, ^^enabled)
	}
	
	/// Enables or disables popup interaction haptic feedback.
	///
	/// - Parameters:
	///   - enabled: Haptic feedback enabled.
	func popupHapticFeedbackEnabled(_ enabled: Bool?) -> some View {
		environment(\.popupHapticFeedbackEnabled, ^^enabled)
	}
	
	/// Enables or disables the popup bar extension under the safe area.
	///
	/// - Parameter enabled: Extend the popup bar under safe area.
	@available(iOS, deprecated: 26.0, message: "No longer supported on iOS 26.0 and later.")
	func popupBarShouldExtendPopupBarUnderSafeArea(_ enabled: Bool?) -> some View {
		environment(\.popupBarShouldExtendPopupBarUnderSafeArea, ^^enabled)
	}
	
	/// Enables or disables the popup bar to automatically inherit its appearance from the bottom docking view, such as toolbar or tab bar.
	///
	/// - Parameter enabled: Inherit the appearance from the popup bar's docking view.
	func popupBarInheritsAppearanceFromDockingView(_ enabled: Bool?) -> some View {
		environment(\.popupBarInheritsAppearanceFromDockingView, ^^enabled)
	}
	
	/// Enables or disables the popup bar to automatically inherit the environment font.
	///
	/// The inherited font will be used as the title font. The subtitle font will be a derivative of the inherited font.
	///
	/// - Parameter enabled: Inherit the environment font.
	func popupBarInheritsEnvironmentFont(_ enabled: Bool?) -> some View {
		environment(\.popupBarInheritsEnvironmentFont, ^^enabled)
	}
	
	/// Sets the popup bar's background style. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter style: The popup bar's background style.
	@available(*, unavailable, renamed: "popupBarBackgroundEffect(_:)")
	func popupBarBackgroundStyle(_ style: UIBlurEffect.Style?) -> some View {
		fatalError("Use popupBarBackgroundEffect(_:) instead")
	}
	
	/// Sets the popup bar's background effect. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter effect: The popup bar's background effect.
	func popupBarBackgroundEffect(_ effect: UIBlurEffect?) -> some View {
		environment(\.popupBarBackgroundEffect, ^^effect)
	}
	
	/// Sets the popup bar's floating background effect. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter effect: The popup bar's floating background effect.
	func popupBarFloatingBackgroundEffect(_ effect: UIVisualEffect?) -> some View {
		environment(\.popupBarFloatingBackgroundEffect, ^^effect)
	}
	
	/// Sets the floating popup bar background shadow.
	///
	/// This has effect only for floating style popup bars.
	///
	/// - Parameters:
	///   - color: The shadow's color.
	///   - radius: A measure of how much to blur the shadow. Larger values
	///     result in more blur.
	///   - x: An amount to offset the shadow horizontally from the view.
	///   - y: An amount to offset the shadow vertically from the view.
	func popupBarFloatingBackgroundShadow(color: Color? = nil, radius: CGFloat, x: CGFloat? = nil, y: CGFloat? = nil) -> some View {
		let standardAppearance = LNPopupBarAppearance()
		standardAppearance.configureWithDefaultFloatingBackground()
		
		let shadow = standardAppearance.floatingBarBackgroundShadow!
		
		if let color = color {
			shadow.shadowColor = UIColor(color)
		}
		
		shadow.shadowBlurRadius = radius
		
		let xx = x ?? shadow.shadowOffset.width
		let yy = y ?? shadow.shadowOffset.height
		shadow.shadowOffset = CGSize(width: xx, height: yy)
		
		return environment(\.popupBarFloatingBackgroundShadow, ^^shadow)
	}
	
#if compiler(>=6.2)
	/// A configuration that defines the corners of the background view for floating bars.
	@available(iOS 26.0, *)
	func popupBarFloatingBackgroundCornerConfiguration(_ configuration: UICornerConfiguration?) -> some View {
		environment(\.popupBarFloatingBackgroundCornerConfiguration, ^^configuration)
	}
#endif
	
	/// Enables or disables full bar width for the custom popup bars.
	func popupBarCustomBarPrefersFullBarWidth(_ prefersFullWidth: Bool?) -> some View {
		environment(\.popupBarCustomBarPrefersFullBarWidth, ^^prefersFullWidth)
	}
	
	/// In wide enough environments, such as iPadOS, enables or disables limiting the width of content of floating bars to a system-determined value.
	func popupBarLimitFloatingContentWidth(_ enabled: Bool?) -> some View {
		environment(\.popupBarLimitFloatingContentWidth, ^^enabled)
	}
	
	/// Sets the popup bar image shadow.
	///
	/// This has effect only for prominent and floating style popup bars.
	///
	/// - Parameters:
	///   - color: The shadow's color.
	///   - radius: A measure of how much to blur the shadow. Larger values
	///     result in more blur.
	///   - x: An amount to offset the shadow horizontally from the view.
	///   - y: An amount to offset the shadow vertically from the view.
	func popupBarImageShadow(color: Color? = nil, radius: CGFloat, x: CGFloat? = nil, y: CGFloat? = nil) -> some View {
		let standardAppearance = LNPopupBarAppearance()
		standardAppearance.configureWithDefaultFloatingBackground()
		
		let shadow = standardAppearance.imageShadow!
		
		if let color = color {
			shadow.shadowColor = UIColor(color)
		}
		
		shadow.shadowBlurRadius = radius
		
		let xx = x ?? shadow.shadowOffset.width
		let yy = y ?? shadow.shadowOffset.height
		shadow.shadowOffset = CGSize(width: xx, height: yy)
		
		return environment(\.popupBarImageShadow, ^^shadow)
	}
	
	/// Sets the display attributes for the popup bar’s title text.
	///
	/// SwiftUI-scoped attributes are partially supported. Open an issue on GitHub if you need something that is not supported.
	@available(iOS 15, *)
	func popupBarTitleTextAttributes(_ attribs: AttributeContainer) -> some View {
		environment(\.popupBarTitleTextAttributes, ^^attribs)
	}
	
	/// Sets the display attributes for the popup bar’s subtitle text.
	///
	/// SwiftUI-scoped attributes are partially supported. Open an issue on GitHub if you need something that is not supported.
	@available(iOS 15, *)
	func popupBarSubtitleTextAttributes(_ attribs: AttributeContainer) -> some View {
		environment(\.popupBarSubtitleTextAttributes, ^^attribs)
	}
	
	/// Sets a custom popup bar view, instead of the default system-provided bars.
	///
	/// If a custom bar view is provided, setting the popup bar style has no effect.
	///
	/// - Parameters:
	///   - wantsDefaultTapGesture: Indicates whether the default tap gesture recognizer should be added to the popup bar.
	///   - wantsDefaultPanGesture: Indicates whether the default pan gesture recognizer should be added to the popup bar.
	///   - wantsDefaultHighlightGesture: Indicates whether the default highlight gesture recognizer should be added to the popup bar.
	///   - popupBarContent: A closure returning the content of the popup bar custom view
	func popupBarCustomView<PopupBarContent>(wantsDefaultTapGesture: Bool = true,
											 wantsDefaultPanGesture: Bool = true,
											 wantsDefaultHighlightGesture: Bool = true,
											 @ViewBuilder popupBarContent: @escaping () -> PopupBarContent) -> some View where PopupBarContent : View {
		environment(\.popupBarCustomBarView, ^^LNPopupBarCustomView(wantsDefaultTapGesture: wantsDefaultTapGesture, wantsDefaultPanGesture: wantsDefaultPanGesture, wantsDefaultHighlightGesture: wantsDefaultHighlightGesture, popupBarCustomBarView: AnyView(popupBarContent())))
	}
	
	/// Adds a context menu to the popup bar.
	///
	/// Use contextual menus to add actions that change depending on the user's
	/// current focus and task.
	///
	/// The following example creates a popup bar with a contextual menu.
	/// Note that the actions invoked by the menu selection could be coded
	/// directly inside the button closures or, as shown below, invoked via
	/// function references.
	///
	/// ```swift
	///	func selectHearts() { ... }
	///	func selectClubs() { ... }
	///	func selectSpades() { ... }
	///	func selectDiamonds() { ... }
	///
	///	TabView {
	///	  // ...
	///	}
	///	.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	///	  ContentView()
	///	}
	///	.popupBarContextMenu {
	///	  Button("♥️ - Hearts", action: selectHearts)
	///	  Button("♣️ - Clubs", action: selectClubs)
	///	  Button("♠️ - Spades", action: selectSpades)
	///	  Button("♦️ - Diamonds", action: selectDiamonds)
	///	}
	///	 ```
	///
	/// - Parameter menuItems: A `contextMenu` that contains one or more menu items.
	func popupBarContextMenu<MenuItems>(@ViewBuilder menuItems: () -> MenuItems) -> some View where MenuItems : View {
		environment(\.popupBarContextMenu, ^^AnyView(menuItems()))
	}
	
	/// Enables or disables popup bar minimization into the bottom bar.
	///
	/// Minimization is supported on iOS 26.0 and later, for tab view containers.
	@ViewBuilder
	func popupBarMinimizationEnabled(_ enabled: Bool?) -> some View {
		environment(\.popupBarMinimizationEnabled, ^^enabled)
	}
	
	/// Gives a low-level access to the `LNPopupBar` object for customization, beyond what is exposed by LNPopupUI.
	///
	///	The popup bar customization closure is called after all other popup bar modifiers have been applied.
	///
	/// - Parameters:
	///   - customizer: A customizing closure that is called to customize the `LNPopupBar` popup bar object.
	func popupBarCustomizer(_ customizer: @escaping (_ popupBar: LNPopupBar) -> Void) -> some View {
		environment(\.popupBarCustomizer, ^^customizer)
	}
	
	/// Gives a low-level access to the `LNPopupContentView` object for customization, beyond what is exposed by LNPopupUI.
	///
	///	The popup content view customization closure is called after all other popup content view modifiers have been applied.
	///
	/// - Parameters:
	///   - customizer: A customizing closure that is called to customize the `LNPopupContentView` popup content view object.
	func popupContentViewCustomizer(_ customizer: @escaping (_ popupContentView: LNPopupContentView) -> Void) -> some View {
		environment(\.popupContentViewCustomizer, ^^customizer)
	}
}

/// Modifiers for directly specifying one or more popup items
public extension View {
	/// Configures the view's popup item to be displayed in a popup bar.
	///
	/// A popup item is used to display in the popup container view's popup bar. A popup item can container a `String`, `AttributedString` or `View` titles and subtitle.
	///
	/// ```swift
	///	// Create a popup item with an image, a custom view title and a button.
	/// let popupItem = PopupItem(id: "intro", image: Image("MyImage")) {
	///		Text("Welcome to ") + Text("LNPopupUI").fontWeight(.heavy) + Text("!")
	/// } buttons: {
	/// 	ToolbarItemGroup(placement: .popupBar) {
	/// 	  Link(destination: url) {
	/// 	  	Label("LNPopupUI", systemImage: "suit.heart.fill")
	/// 	  }
	/// 	}
	/// }
	///
	///	TabView {
	///	  // ...
	///	}
	///	.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	///	  ContentView()
	///	    .popupItem(popupItem)
	///	}
	///	 ```
	///
	/// - Warning: You should never mix direct popup item specifier modifiers with default popup item modifiers, such as ``SwiftUICore/View/popupTitle(_:subtitle:tableName:bundle:titleComment:subtitleComment:)``, in the same popup content hierarchy.
	/// - Parameters:
	///   - popupItem: The popup item to display in a popup bar.
	func popupItem<Identifier: Hashable, TitleContent, SubtitleContent, ButtonToolbarContent: ToolbarContent>(_ popupItem: PopupItem<Identifier, TitleContent, SubtitleContent, ButtonToolbarContent>) -> some View {
		preference(key: LNPopupItemPreferenceKey.self, value: %%AnyPopupItem(popupItem))
	}
	
	/// Configures the view's popup item to be displayed in a popup bar.
	///
	/// A popup item is used to display in the popup container view's popup bar. A popup item can container a `String`, `AttributedString` or `View` titles and subtitle.
	///
	/// ```swift
	///	TabView {
	///	  // ...
	///	}
	///	.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	///	  ContentView()
	///	    .popupItem {
	///	      // Create a popup item with an image, a custom view title and a button.
	///       PopupItem(id: "intro", image: Image("MyImage")) {
	///	      	Text("Welcome to ") + Text("LNPopupUI").fontWeight(.heavy) + Text("!")
	///       } buttons: {
	///       	ToolbarItemGroup(placement: .popupBar) {
	///       	  Link(destination: url) {
	///       	  	Label("LNPopupUI", systemImage: "suit.heart.fill")
	///       	  }
	///       	}
	///       }
	///	    }
	///	}
	///	 ```
	///
	/// - Warning: You should never mix direct popup item specifier modifiers with default popup item modifiers, such as ``SwiftUICore/View/popupTitle(_:subtitle:tableName:bundle:titleComment:subtitleComment:)``, in the same popup content hierarchy.
	/// - Parameters:
	///   - provider: A closure that returns the popup item to display in a popup bar.
	func popupItem<Identifier: Hashable, TitleContent, SubtitleContent, ButtonToolbarContent: ToolbarContent>(provider: () -> PopupItem<Identifier, TitleContent, SubtitleContent, ButtonToolbarContent>) -> some View {
		preference(key: LNPopupItemPreferenceKey.self, value: %%AnyPopupItem(provider()))
	}
}

/// Modifiers for the default popup item
public extension View {
	/// Configures the default popup item's title and subtitle.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - localizedTitleKey: The localized title key to display.
	///   - localizedSubtitleKey: The localized subtitle key to display. Defaults to `nil`.
	///   - tableName: The name of the string table to search. If `nil`, use the table in the `Localizable.strings` file.
	///   - bundle: The bundle containing the strings file. If `nil`, use the main bundle.
	///   - titleComment: Contextual information about the title key-value pair.
	///   - subtitleComment: Contextual information about the subtitle key-value pair.
	func popupTitle(_ localizedTitleKey: LocalizedStringKey, subtitle localizedSubtitleKey: LocalizedStringKey? = nil, tableName: String? = nil, bundle: Bundle? = nil, titleComment: String? = nil, subtitleComment: String? = nil) -> some View {
		let subtitle: String?
		if let localizedSubtitleKey = localizedSubtitleKey {
			subtitle = NSLocalizedString(localizedSubtitleKey.stringKey, tableName: tableName, bundle: bundle ?? .main, value: localizedSubtitleKey.stringKey, comment: subtitleComment ?? "")
		} else {
			subtitle = nil
		}
		
		return popupTitle(verbatim: NSLocalizedString(localizedTitleKey.stringKey, tableName: tableName, bundle: bundle ?? .main, value: localizedTitleKey.stringKey, comment: titleComment ?? ""), subtitle: subtitle)
	}
	
	@_disfavoredOverload
	/// Configures the default popup item's title and subtitle.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - titleContent: The localized title key to display.
	///   - subtitleContent: The localized subtitle key to display. Defaults to `nil`.
	func popupTitle<S>(_ titleContent: S, subtitle subtitleContent: S? = nil) -> some View where S : StringProtocol {
		let subtitle: String?
		if let subtitleContent = subtitleContent {
			subtitle = String(subtitleContent)
		} else {
			subtitle = nil
		}
		
		return popupTitle(verbatim: String(titleContent), subtitle: subtitle)
	}
	
	/// Configures the default popup item's title and subtitle with custom views.
	///
	/// When using custom labels, marquee scroll and text attributes settings have no effect.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - titleContent: A view that describes the popup's title.
	///   - subtitleContent: A view that describes the popup's subtitle.
	func popupTitle<TitleContent, SubtitleContent>(@ViewBuilder _ titleContent: () -> TitleContent, @ViewBuilder subtitle subtitleContent: () -> SubtitleContent = { EmptyView() }) -> some View where TitleContent : View, SubtitleContent : View {
		preference(key: LNPopupTextTitlePreferenceKey.self, value: %%LNPopupTitleContentData(titleView: AnyView(erasing: titleContent()), subtitleView: AnyView(erasing: subtitleContent())))
	}
	
	/// Configures the default popup item's title and subtitle.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle<S>(verbatim title: S, subtitle: S? = nil) -> some View where S : StringProtocol {
		popupTitle(verbatim: String(title), subtitle: subtitle == nil ? nil : String(subtitle!))
	}
	
	/// Configures the default popup item's title and subtitle.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle(verbatim title: String, subtitle: String? = nil) -> some View {
		preference(key: LNPopupTitlePreferenceKey.self, value: %%LNPopupTitleData(title: title, subtitle: subtitle))
	}
	
	/// Configures the default popup item's image.
	///
	/// Setting to `nil` will hide image from the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - image: The image to use.
	///   - resizable: Mark the image as resizable. Defaults to `true`. If you'd like to control this on your own, set this parameter to `false`.
	///   - aspectRatio: The ratio of width to height to use for the resulting popup bar image. Use `nil` to maintain the current aspect ratio.
	///   - contentMode: A flag that indicates whether this view fits or fills the popup bar image view.
	func popupImage(_ image: Image?, resizable: Bool = true, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) -> some View {
		if let image {
			preference(key: LNPopupImagePreferenceKey.self, value: %%LNPopupImageData(image: image, resizable: resizable, aspectRatio: aspectRatio, contentMode: contentMode))
		} else {
			preference(key: LNPopupImagePreferenceKey.self, value: nil)
		}
	}
	
	/// Configures the default popup item's progress.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - progress: The popup bar progress.
	func popupProgress(_ progress: Float) -> some View {
		preference(key: LNPopupProgressPreferenceKey.self, value: %%progress)
	}
	
	/// Sets the bar buttons to display on the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: A view representing the bar buttons that appear on the popup bar.
	func popupBarButtons<Content>(@ViewBuilder _ content: @escaping () -> Content) -> some View where Content : View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(content)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: Toolbar content representing the bar buttons that appear on the popup bar.
	@available(iOS, introduced: 14.0)
	func popupBarButtons<Content>(@ToolbarContentBuilder _ content: @escaping () -> Content) -> some View where Content : ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(content)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
}

public
extension View {
	/// Designates this view as the popup interaction container. Only gestures within this view will be considered for popup interaction, such as dismissal.
	///
	/// @note This method layers a background view behind this view. The background view might interfere with interaction of elements behind it. Use with care.
	func popupInteractionContainer() -> some View {
		background(LNPopupUIInteractionContainerBackgroundView().accessibilityHidden(true))
	}
	
	/// Apply this modifier to designate a view as the popup transition target. The system will transition to and from this view when the popup opens and closes.
	///
	/// There should only be a single transition target per popup content view. Applying more will result in undefined behavior.
	///
	/// - Note: Transitions are only available for prominent and floating popup bar styles with drag interaction style. Any other combination will result in no transition.
	func popupTransitionTarget() -> some View {
		if #available(iOS 26, *) {
			return overlay(LNPopupUITransitionForeground().accessibilityHidden(true)).compositingGroup()
		}
		
		return background(LNPopupUITransitionBackground().accessibilityHidden(true)).overlay(LNPopupUITransitionForeground().accessibilityHidden(true))
	}
	
	/// Sets the popup content background color. Provider `nil`, `.clear` or any color with opacity less than 1.0 to have a translucent background.
	/// - Parameter color: The color to use or `nil`.
	func popupContentBackgroundColor(_ color: Color?) -> some View {
		preference(key: LNPopupContentBackgroundColorPreferenceKey.self, value: %%color.map { UIColor($0) })
	}
	
	/// Sets the popup content background color. Provider `nil`, `.clearColor` or any color with alpha less than 1.0 to have a translucent background.
	/// - Parameter color: The color to use or `nil`.
	@_disfavoredOverload
	func popupContentBackgroundColor(_ color: UIColor?) -> some View {
		preference(key: LNPopupContentBackgroundColorPreferenceKey.self, value: %%color)
	}
}

/// Deprecations
public extension View {
	/// Configures the default popup item's leading bar buttons.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	@available(iOS, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarLeadingButtons<LeadingContent>(@ViewBuilder leading: @escaping () -> LeadingContent) -> some View where LeadingContent: View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading bar items are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarLeadingButtons<LeadingContent>(@ToolbarContentBuilder leading: @escaping () -> LeadingContent) -> some View where LeadingContent: ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarTrailingButtons<TrailingContent>(@ViewBuilder trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarTrailingButtons<TrailingContent>(@ToolbarContentBuilder trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarButtons<LeadingContent, TrailingContent>(@ViewBuilder leading: @escaping () -> LeadingContent, @ViewBuilder trailing: @escaping () -> TrailingContent) -> some View where LeadingContent: View, TrailingContent: View {
		let wrapperCreatorLeading = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		let wrapperCreatorTrailing = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreatorLeading)
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreatorTrailing)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated: 26.0, message: "Non-floating bars are no longer supported on iOS 26.0 and later.")
	func popupBarButtons<LeadingContent, TrailingContent>(@ToolbarContentBuilder leading: @escaping () -> LeadingContent, @ToolbarContentBuilder trailing: @escaping () -> TrailingContent) -> some View where LeadingContent: ToolbarContent, TrailingContent: ToolbarContent {
		let wrapperCreatorLeading = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		let wrapperCreatorTrailing = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreatorLeading)
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreatorTrailing)
	}
	
	/// Configures the default popup item's bar buttons.
	///
	/// For compact popup bars, this is equivalent to trailing bar buttons.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: A view representing the bar buttons that appear on the popup bar.
	@available(*, deprecated, renamed: "popupBarButtons(_:)")
	func popupBarItems<Content>(@ViewBuilder _ content: @escaping () -> Content) -> some View where Content : View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(content)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For compact popup bars, this is equivalent to trailing bar buttons.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: Toolbar content representing the bar buttons that appear on the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarButtons(_:)")
	func popupBarItems<Content>(@ToolbarContentBuilder _ content: @escaping () -> Content) -> some View where Content : ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(content)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarLeadingButtons(_:)")
	func popupBarLeadingItems<LeadingContent>(@ViewBuilder leading: @escaping () -> LeadingContent) -> some View where LeadingContent: View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarLeadingButtons(_:)")
	func popupBarLeadingItems<LeadingContent>(@ToolbarContentBuilder leading: @escaping () -> LeadingContent) -> some View where LeadingContent: ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarTrailingButtons(_:)")
	func popupBarTrailingItems<TrailingContent>(@ViewBuilder trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: View {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarTrailingButtons(_:)")
	func popupBarTrailingItems<TrailingContent>(@ToolbarContentBuilder trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: ToolbarContent {
		let wrapperCreator = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreator)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarButtons(leading:trailing:)")
	func popupBarItems<LeadingContent, TrailingContent>(@ViewBuilder leading: @escaping () -> LeadingContent, @ViewBuilder trailing: @escaping () -> TrailingContent) -> some View where LeadingContent: View, TrailingContent: View {
		let wrapperCreatorLeading = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		let wrapperCreatorTrailing = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreatorLeading)
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreatorTrailing)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// @note Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported. For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Warning: You should never mix direct popup item specifier modifiers, such as ``SwiftUICore/View/popupItem(_:)``, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarButtons(leading:trailing:)")
	func popupBarItems<LeadingContent, TrailingContent>(@ToolbarContentBuilder leading: @escaping () -> LeadingContent, @ToolbarContentBuilder trailing: @escaping () -> TrailingContent) -> some View where LeadingContent: ToolbarContent, TrailingContent: ToolbarContent {
		let wrapperCreatorLeading = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(leading)))
		}
		let wrapperCreatorTrailing = LNPopupAnyViewWrapperCreator {
			LNPopupAnyViewWrapper(anyView: AnyView(barItemContainer(trailing)))
		}
		
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%wrapperCreatorLeading)
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%wrapperCreatorTrailing)
	}
}
