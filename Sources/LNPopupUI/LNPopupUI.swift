//
//  LNPopupUI.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import LNPopupController

public extension View {
	
	/// Presents a popup bar with popup content.
	///
	/// - Parameters:
	///   - isBarPresented: A binding to whether the popup bar is presented.
	///   - isPopupOpen: A binding to whether the popup is open. (optional)
	///   - onOpen: A closure executed when the popup opens. (optional)
	///   - onClose: A closure executed when the popup closes. (optional)
	///   - popupContent: A closure returning the content of the popup.
	func popup<PopupContent>(isBarPresented: Binding<Bool>, isPopupOpen: Binding<Bool>? = nil, onOpen: (() -> Void)? = nil, onClose: (() -> Void)? = nil, @ViewBuilder popupContent: @escaping () -> PopupContent) -> some View where PopupContent : View {
		return LNPopupViewWrapper<Self, PopupContent>(isBarPresented: isBarPresented, isOpen: isPopupOpen ?? Binding.constant(false), onOpen: onOpen, onClose: onClose, popupContent: popupContent) {
			self
		}.edgesIgnoringSafeArea(.all)
	}
	
	/// Sets the popup interaction style.
	///
	/// - Parameter style: The popup interaction style.
	func popupInteractionStyle(_ style: LNPopupInteractionStyle) -> some View {
		return environment(\.popupInteractionStyle, style)
	}
	
	/// Sets the popup close button style.
	///
	/// - Parameter style: The popup close button style.
	func popupCloseButtonStyle(_ style: LNPopupCloseButtonStyle) -> some View {
		return environment(\.popupCloseButtonStyle, style)
	}
	
	/// Sets the popup bar style.
	///
	/// Setting a custom popup bar view will methis this modifier have no effect.
	///
	/// - Parameter style: The popup bar style.
	func popupBarStyle(_ style: LNPopupBarStyle) -> some View {
		return environment(\.popupBarStyle, style)
	}
	
	/// Sets the popup bar's progress style.
	///
	/// - Parameter style: The popup bar's progress style.
	func popupBarProgressViewStyle(_ style: LNPopupBarProgressViewStyle) -> some View {
		return environment(\.popupBarProgressViewStyle, style)
	}
	
	/// Enables or disables the popup bar marquee scrolling. When enabled, titles and subtitles that are longer than the space available will scroll text over time.
	///
	/// - Parameter enabled: Marquee scroll enabled.
	func popupBarMarqueeScrollEnabled(_ enabled: Bool) -> some View {
		return environment(\.popupBarMarqueeScrollEnabled, enabled)
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
		return environment(\.popupBarCustomBarView, LNPopupBarCustomView(wantsDefaultTapGesture: wantsDefaultTapGesture, wantsDefaultPanGesture: wantsDefaultPanGesture, wantsDefaultHighlightGesture: wantsDefaultHighlightGesture, popupBarCustomBarView: AnyView(popupBarContent())))
	}
}

public extension View {
	/// Configures the view's popup bar title and subtitle.
	///
	/// - Parameters:
	///   - localizedTitleKey: The localized title key to display.
	///   - localizedSubtitleKey: The localized subtitle key to display. Defaults to `nil`.
	func popupTitle<S>(_ localizedTitleKey: S, subtitle localizedSubtitleKey: S? = nil) -> some View where S : StringProtocol {
		let subtitle: String?
		if let localizedSubtitleKey = localizedSubtitleKey {
			subtitle = NSLocalizedString(String(localizedSubtitleKey), comment: "")
		} else {
			subtitle = nil
		}
		
		return popupTitle(verbatim: NSLocalizedString(String(localizedTitleKey), comment: ""), subtitle: subtitle)
	}
	
	/// Configures the view's popup bar title and subtitle.
	///
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle<S>(verbatim title: S, subtitle: S? = nil) -> some View where S : StringProtocol {
		return popupTitle(verbatim: String(title), subtitle: subtitle == nil ? nil : String(subtitle!))
	}
	
	/// Configures the view's popup bar title and subtitle.
	///
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle(verbatim title: String, subtitle: String? = nil) -> some View {
		return self.preference(key: LNPopupTitlePreferenceKey.self, value: LNPopupTitleData(title: title, subtitle: subtitle))
	}
	
	/// Configures the view's popup bar image.
	///
	/// - Parameters:
	///   - image: The image to use.
	func popupImage(_ image: Image) -> some View {
		return self.preference(key: LNPopupImagePreferenceKey.self, value: image)
	}
	
	/// Configures the view's popup bar progress.
	///
	/// - Parameters:
	///   - progress: The popup bar progress.
	func popupProgress(_ progress: Float) -> some View {
		return self.preference(key: LNPopupProgressPreferenceKey.self, value: progress)
	}
	
	/// Sets the bar button items to display on the popup bar.
	///
	/// @note For compact popup bars, this is equivalent to trailing button items.
	///
	/// - Parameter content: A view that appears on the trailing edge of the popup bar.
	func popupBarItems<Content>(@ViewBuilder _ content: () -> Content) -> some View where Content : View {
		return self
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: LNPopupAnyViewWrapper(anyView: AnyView(content())))
	}
	
	/// Sets the bar button items to display on the popup bar.
	///
	/// @note For prominent popup bars, leading bar items are positioned in the trailing edge of the popup bar.
	///
	/// - Parameter leading: A view that appears on the leading edge of the popup bar.
	func popupBarItems<LeadingContent>(@ViewBuilder leading: () -> LeadingContent) -> some View where LeadingContent: View {
		return self
			.preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: LNPopupAnyViewWrapper(anyView: AnyView(leading())))
	}
	
	/// Sets the bar button items to display on the popup bar.
	///
	/// - Parameter trailing: A view that appears on the trailing edge of the popup bar.
	func popupBarItems<TrailingContent>(@ViewBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: View {
		return self
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: LNPopupAnyViewWrapper(anyView: AnyView(trailing())))
	}
	
	/// Sets the bar button items to display on the popup bar.
	///
	/// @note For prominent popup bars, leading and trailing bar items are positioned in the trailing edge of the popup bar.
	///
	/// - Parameter leading: A view that appears on the leading edge of the popup bar.
	/// - Parameter trailing: A view that appears on the trailing edge of the popup bar.
	func popupBarItems<LeadingContent, TrailingContent>(@ViewBuilder leading: () -> LeadingContent, @ViewBuilder trailing: () -> TrailingContent) -> some View where LeadingContent: View, TrailingContent: View {
		return self
			.preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: LNPopupAnyViewWrapper(anyView: AnyView((leading()))))
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: LNPopupAnyViewWrapper(anyView: AnyView((trailing()))))
	}
}

public extension View {
	/// Configures the view's popup bar image.
	///
	/// - Parameters:
	///   - name: The name of the image resource to lookup.
	///   - bundle: The bundle to search for the image resource and localization content. If `nil`, uses the main `Bundle`. Defaults to `nil`.
	@available(*, deprecated)
	func popupImage(_ name: String, bundle: Bundle? = nil) -> some View {
		return self.popupImage(Image(name, bundle: bundle))
	}
	
	/// Configures the view's popup bar image with a system symbol image.
	///
	/// - Parameters:
	///   - systemName: The name of the system symbol image. Use the SF Symbols app to look up the names of system symbol images.
	@available(*, deprecated)
	func popupImage(systemName: String) -> some View {
		return self.popupImage(Image(systemName: systemName))
	}
	
	/// Configures the view's popup bar image based on a @c UIImage.
	///
	/// - Parameters:
	///   - uiImage: The image to use
	@available(*, deprecated)
	func popupImage(_ uiImage: UIImage) -> some View {
		return self.popupImage(Image(uiImage: uiImage))
	}
	
	/// Configures the view's popup bar image based on a @c CGImage.
	///
	/// - Parameters:
	///   - cgImage: the base graphical image
	///   - scale: the scale factor the image is intended for (e.g. 1.0, 2.0, 3.0)
	///   - orientation: the orientation of the image
	@available(*, deprecated)
	func popupImage(_ cgImage: CGImage, scale: CGFloat, orientation: UIImage.Orientation = .up) -> some View {
		return self.popupImage(Image(decorative: cgImage, scale: scale, orientation: UIImageOrientationToImageOrientation(orientation)))
	}
}
