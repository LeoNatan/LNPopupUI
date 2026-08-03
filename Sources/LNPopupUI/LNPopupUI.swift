//
//  LNPopupUI.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNSwiftUIUtils
import os.log
@_exported import LNPopupController

fileprivate
let logger = {
	Logger(subsystem: "com.LeoNatan.LNPopupUI", category: "APIUsage")
}()

public extension ToolbarItemPlacement {
#if swift(>=6.0)
	@MainActor
#endif
	static let popupBar: ToolbarItemPlacement = .bottomBar
}

public
struct PopupBarLayoutProxy: Equatable {
	public
	let effectiveBarStyle: LNPopupBar.Style
	public
	let userInterfaceIdiom: UIUserInterfaceIdiom
	public
	let horizontalSizeClass: UserInterfaceSizeClass?
	public
	let effectiveBarContentSize: CGSize
}

// MARK: - Popup Scene Presentation

/// Modifiers for popup scene presentation.
///
/// These modifiers should be applied to the outer-most view of your scene as possible.
public extension View {
	
	/// Presents a popup bar with a popup content.
	///
	/// - Parameters:
	///   - isBarPresented: A binding to whether the popup bar is presented.
	///   - isPopupOpen: A binding to whether the popup is open. (optional)
	///   - onOpen: A closure executed when the popup opens. (optional)
	///   - onClose: A closure executed when the popup closes. (optional)
	///   - popupContent: A closure returning the content of the popup.
	func popup<PopupContent>(isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, @ViewBuilder popupContent: () -> PopupContent) -> some View where PopupContent : View {
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
}

// MARK: - Popup Bar Configuration

/// Popup bar configuration modifiers
///
/// These modifiers should be applied to the same view you used for presentation.
public extension View {
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
	
	/// Sets the popup bar's background effect. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter effect: The popup bar's background effect.
	func popupBarBackgroundEffect(_ effect: UIBlurEffect?) -> some View {
		environment(\.popupBarBackgroundEffect, ^?effect)
	}
	
	/// Sets the popup bar's floating background effect. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter effect: The popup bar's floating background effect.
	func popupBarFloatingBackgroundEffect(_ effect: UIVisualEffect?) -> some View {
		environment(\.popupBarFloatingBackgroundEffect, ^?effect)
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
		
		return environment(\.popupBarFloatingBackgroundShadow, ^?shadow)
	}
	
	/// A configuration that defines the corners of the background view for floating bars.
	@available(iOS 26.0, *)
	func popupBarFloatingBackgroundCornerConfiguration(_ configuration: UICornerConfiguration?) -> some View {
		environment(\.popupBarFloatingBackgroundCornerConfiguration, ^^configuration)
	}
	
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
		
		return environment(\.popupBarImageShadow, ^?shadow)
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
	
	/// Enables or disables inheriting bottom docking view metrics for the popup bar, including minimization into tab bars.
	///
	/// When enabled, floating popup bars will inherit certain metrics from their bottom docking views, such as toolbars and tab bars. This also enables popup bar minimization into tab bars.
	///
	/// Supported on iOS 26.0 and later.
	func popupBarInheritsBottomBarMetrics(_ enabled: Bool?) -> some View {
		environment(\.popupBarInheritsBottomBarMetrics, ^^enabled)
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
											 @ViewBuilder popupBarContent: () -> PopupBarContent) -> some View where PopupBarContent : View {
		environment(\.popupBarCustomBarView, ^^LNPopupBarCustomView(wantsDefaultTapGesture: wantsDefaultTapGesture, wantsDefaultPanGesture: wantsDefaultPanGesture, wantsDefaultHighlightGesture: wantsDefaultHighlightGesture, popupBarCustomBarView: AnyView(popupBarContent())))
	}
	
	/// Gives a low-level access to the `LNPopupBar` object for customization, beyond what is exposed by LNPopupUI.
	///
	///	The popup bar customization closure is called after all other popup bar modifiers have been applied.
	///
	/// - Note: If you've used the `popupBarCustomView()` modifier, do not access the popup bar's `customBarViewController` or modify its `barStyle`.
	/// - Parameters:
	///   - customizer: A customizing closure that is called to customize the `LNPopupBar` popup bar object.
	func popupBarCustomizer(_ customizer: @escaping (_ popupBar: LNPopupBar) -> Void) -> some View {
		environment(\.popupBarCustomizer, ^^customizer)
	}
	
	/// Adds an action to be performed when a value, created from a
	/// popup bar layout proxy, changes.
	///
	/// The geometry of the popup bar can change frequently, especially if
	/// the popup bar is an environment where the containing view's size changes.
	///
	/// You should avoid updating large parts of your app whenever
	/// the popup bar geometry changes. To aid in this, you provide two
	/// closures to this modifier:
	///   * transform: This converts a value of `PopupBarLayoutProxy` to
	///     your own data type.
	///   * action: This provides the data type you created in `of`
	///     and is called whenever the data type changes.
	///
	/// - Parameters:
	///   - type: The type of value transformed from a `PopupBarLayoutProxy`.
	///   - transform: A closure that transforms a `PopupBarLayoutProxy`
	///     to your type.
	///   - action: A closure to run when the transformed data changes.
	///     - term newValue: The new value that failed the comparison check.
	func onPopupBarGeometryChange<T>(for type: T.Type,
									 of transform: @escaping @Sendable (PopupBarLayoutProxy) -> T,
									 action: @escaping (_ newValue: T) -> Void
	) -> some View where T: Equatable, T: Sendable {
        modifier(PopupBarGeometryChangeModifier(transform: transform, action: action))
	}
	
	/// Adds an action to be performed when a value, created from a
	/// popup bar layout proxy, changes.
	///
	/// The geometry of the popup bar can change frequently, especially if
	/// the popup bar is an environment where the containing view's size changes.
	///
	/// You should avoid updating large parts of your app whenever
	/// the popup bar geometry changes. To aid in this, you provide two
	/// closures to this modifier:
	///   * transform: This converts a value of `PopupBarLayoutProxy` to
	///     your own data type.
	///   * action: This provides the data type you created in `of`
	///     and is called whenever the data type changes.
	///
	/// - Parameters:
	///   - type: The type of value transformed from a `PopupBarLayoutProxy`.
	///   - transform: A closure that transforms a `PopupBarLayoutProxy`
	///     to your type.
	///   - action: A closure to run when the transformed data changes.
	///     - term oldValue: The old value that failed the comparison check.
	///     - term newValue: The new value that failed the comparison check.
	func onPopupBarGeometryChange<T>(for type: T.Type,
									 of transform: @escaping @Sendable (PopupBarLayoutProxy) -> T,
									 action: @escaping (_ oldValue: T?, _ newValue: T) -> Void
    ) -> some View where T: Equatable, T: Sendable {
        modifier(PopupBarGeometryChangeModifier(transform: transform, action: action))
	}
}

// MARK: - Popup Presentation and Content View Configuration

/// Popup presentation and content view configuration modifiers
///
/// These modifiers should be applied to the same view you used for presentation.
public extension View {
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
	
	/// Enables or disables popup interaction haptic feedback.
	///
	/// - Parameters:
	///   - enabled: Haptic feedback enabled.
	func popupHapticFeedbackEnabled(_ enabled: Bool?) -> some View {
		environment(\.popupHapticFeedbackEnabled, ^^enabled)
	}
	
	/// Enables or disables content transition in the popup content view.
	///
	/// Disable this in cases where the transition introduces unwanted layout issues.
	///
	/// Supported on iOS 26.0 and later.
	///
	/// - Note: This does not disable popup image transitions.
	func popupContentAllowsContentTransition(_ allows: Bool?) -> some View {
		environment(\.popupContentAllowsContentTransition, ^^allows)
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

// MARK: - Single Popup Item

/// Modifiers for specifying a single popup item.
///
/// These modifiers should be applied to the view inside the popup content.
public extension View {
	/// Configures the view's popup item to be displayed in a popup bar.
	///
	/// Popup items are used to display in the popup containing view's popup bar.
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
	///	        Text("Welcome to ") + Text("LNPopupUI").fontWeight(.heavy) + Text("!")
	///       } buttons: {
	///         ToolbarItemGroup(placement: .popupBar) {
	///       	  Link(destination: url) {
	///             Label("LNPopupUI", systemImage: "suit.heart.fill")
	///       	  }
	///       	}
	///       }
	///	    }
	///	}
	///	 ```
	///
	/// - Note: Never mix between the different popup item modifier families in the same popup content hierarchy. Either use a single popup item providing modifier, such as `View.popupItem(popupItem:)`, a multiple popup item providing modifier, such as `View.popupItems(selection:items:)` or modifiers to update the default popup item, such as `View.popupTitle(_:subtitle:tableName:bundle:titleComment:subtitleComment:)`.
	/// - Parameters:
	///   - popupItem: The popup item to display in a popup bar.
	func popupItem<Identifier: Hashable>(_ popupItem: PopupItem<Identifier>) -> some View {
		preference(key: LNPopupItemPreferenceKey.self, value: %%popupItem.eraseToAnyHashableIdentifier())
	}
	
	/// Configures the view's popup item to be displayed in a popup bar.
	///
	/// Popup items are used to display in the popup containing view's popup bar.
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
	///	        Text("Welcome to ") + Text("LNPopupUI").fontWeight(.heavy) + Text("!")
	///       } buttons: {
	///         ToolbarItemGroup(placement: .popupBar) {
	///       	  Link(destination: url) {
	///             Label("LNPopupUI", systemImage: "suit.heart.fill")
	///       	  }
	///       	}
	///       }
	///	    }
	///	}
	///	 ```
	///
	/// - Note: Never mix between the different popup item modifier families in the same popup content hierarchy. Either use a single popup item providing modifier, such as `View.popupItem(popupItem:)`, a multiple popup item providing modifier, such as `View.popupItems(selection:items:)` or modifiers to update the default popup item, such as `View.popupTitle(_:subtitle:tableName:bundle:titleComment:subtitleComment:)`.
	/// - Parameters:
	///   - popupItem: The popup item to display in a popup bar.
	func popupItem<Identifier: Hashable>(popupItem: () -> PopupItem<Identifier>) -> some View {
		preference(key: LNPopupItemPreferenceKey.self, value: %%popupItem().eraseToAnyHashableIdentifier())
	}
}

// MARK: - Multiple Popup Items & Paging Support

/// Modifiers for specifying multiple popup items with paging support.
///
/// These modifiers should be applied to the view inside the popup content.
public extension View {
	/// Configures the view's popup items to be displayed in a popup bar.
	///
	/// The popup item list must contain at least one item.
	///
	/// This modifier enables popup item paging. If the popup item list contains more than one item, the user is able to swipe left and right on the popup bar to select a different item. The selected item identifier is reflected in the provided selection binding.
	///
	/// Popup items are used to display in the popup containing view's popup bar.
	///
	/// ```swift
	/// TabView {
	///   // ...
	/// }
	/// .popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	///   ContentView()
	///     .popupItems(selection: $currentSong) {
	///       for song in playlist {
	///         // Create a popup item for each song in the playlist, with the song's art, name, album and playback controls.
	///         PopupItem(id: song, title: song.name, subtitle: song.albumName, image: song.art, progress: playbackState.progress) {
	///           playbackButtons(for: song, with: playbackState)
	///         }
	///       }
	///     }
	/// }
	///	 ```
	///
	/// - Note: Never mix between the different popup item modifier families in the same popup content hierarchy. Either use a single popup item providing modifier, such as `View.popupItem(popupItem:)`, a multiple popup item providing modifier, such as `View.popupItems(selection:items:)` or modifiers to update the default popup item, such as `View.popupTitle(_:subtitle:tableName:bundle:titleComment:subtitleComment:)`.
	/// - Parameters:
	///   - selection: The selection in the popup item list. The value of this binding must match the `id` of the popup items provided by `items`.
	///   - items: The popup items.
	@ViewBuilder
	func popupItems<Identifier: Hashable>(selection: Binding<Identifier>, @PopupItemBuilder<Identifier> items: () -> [PopupItem<Identifier>]) -> some View {
		let items = items()
		if items.isEmpty {
			let _ = logger.error("The popup item list cannot be empty; ignoring.")
			preference(key: LNPopupItemsPreferenceKey.self, value: nil)
		} else {
			//The compiler has ensured all popup item identifiers in this list have the same underlying type, so it's safe to cast to and from AnyHashable here.
			preference(key: LNPopupItemsPreferenceKey.self, value: %%LNPopupItemData(selection: Binding {
				AnyHashable(selection.wrappedValue)
			} set: { newValue in
				selection.wrappedValue = newValue as! Identifier
			}, popupItems: items.map { $0.eraseToAnyHashableIdentifier() }))
		}
	}
}

// MARK: - Transition and Interaction

/// Modifiers for specifying transition and interaction targets
///
/// These modifiers should be applied to the view inside the popup content.
public extension View {
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

// MARK: Deprecations

/// Deprecations
public extension View {
	/// Enables or disables popup bar minimization into the bottom bar.
	///
	/// Minimization is supported on iOS 26.0 and later, for tab view containers.
	@available(iOS, introduced: 14.0, deprecated: 27.0, renamed: "popupBarInheritsBottomBarMetrics(_:)")
	func popupBarMinimizationEnabled(_ enabled: Bool?) -> some View {
		popupBarInheritsBottomBarMetrics(enabled)
	}
	
	/// Enables or disables the popup bar extension under the safe area.
	///
	/// - Parameter enabled: Extend the popup bar under safe area.
	@available(iOS, deprecated: 26.0, message: "No longer supported on iOS 26.0 and later.")
	func popupBarShouldExtendPopupBarUnderSafeArea(_ enabled: Bool?) -> some View {
		environment(\.popupBarShouldExtendPopupBarUnderSafeArea, ^^enabled)
	}
	
	
	/// Sets the popup bar's background style. Use `nil` to use the most appropriate background style for the environment.
	///
	/// - Parameter style: The popup bar's background style.
	@available(*, unavailable, renamed: "popupBarBackgroundEffect(_:)")
	func popupBarBackgroundStyle(_ style: UIBlurEffect.Style?) -> some View {
		fatalError("Use popupBarBackgroundEffect(_:) instead")
	}
}
