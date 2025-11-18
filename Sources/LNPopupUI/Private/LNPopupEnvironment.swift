//
//  LNPopupEnvironment.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNPopupController

prefix operator ^^
prefix operator ^?

#if swift(>=6.0)
@MainActor
#endif
internal final class LNPopupEnvironmentConsumer<T> {
	private let wrapped: T
	private unowned var consumer: AnyObject? = nil
	
	init?(_ wrapped: T?) {
		guard let wrapped = wrapped else {
			return nil
		}
		
		self.wrapped = wrapped
	}
	
	func consume(_ consumer: AnyObject) -> T? {
		guard self.consumer == nil || self.consumer === consumer else {
			return nil
		}
		
		self.consumer = consumer
		return wrapped
	}
}

internal
prefix func ^^<T>(_ wrapped: T?) -> LNPopupEnvironmentConsumer<T>? {
	LNPopupEnvironmentConsumer(wrapped)
}

#if swift(>=6.0)
@MainActor
#endif
internal final class LNPopupEnvironmentNullableConsumer<T> {
	private let wrapped: T?
	private unowned var consumer: AnyObject? = nil
	
	init?(_ wrapped: T?) {
		self.wrapped = wrapped
	}
	
	func consume(_ consumer: AnyObject) -> T?? {
		guard self.consumer == nil || self.consumer === consumer else {
			return nil
		}
		
		self.consumer = consumer
		return wrapped
	}
}

internal
prefix func ^?<T>(_ wrapped: T?) -> LNPopupEnvironmentNullableConsumer<T>? {
	LNPopupEnvironmentNullableConsumer(wrapped)
}

internal extension EnvironmentValues {
	@Entry var popupInteractionStyle: LNPopupEnvironmentConsumer<UIViewController.PopupInteractionStyle>?
	@Entry var popupCloseButtonStyle: LNPopupEnvironmentConsumer<LNPopupCloseButton.Style>?
	@Entry var popupCloseButtonPositioning: LNPopupEnvironmentConsumer<LNPopupCloseButton.Positioning>?
	@Entry var popupBarStyle: LNPopupEnvironmentConsumer<LNPopupBar.Style>?
	@Entry var popupBarProgressViewStyle: LNPopupEnvironmentConsumer<LNPopupBar.ProgressViewStyle>?
	@Entry var popupBarMarqueeScrollEnabled: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarShineEnabled: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarLimitFloatingContentWidth: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupHapticFeedbackEnabled: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarMarqueeRate: LNPopupEnvironmentConsumer<CGFloat>?
	@Entry var popupBarMarqueeDelay: LNPopupEnvironmentConsumer<TimeInterval>?
	@Entry var popupBarCoordinateMarqueeAnimations: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarShouldExtendPopupBarUnderSafeArea: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarInheritsAppearanceFromDockingView: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarInheritsEnvironmentFont: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarBackgroundEffect: LNPopupEnvironmentNullableConsumer<UIBlurEffect>?
	@Entry var popupBarFloatingBackgroundEffect: LNPopupEnvironmentNullableConsumer<UIVisualEffect>?
	@Entry var popupBarFloatingBackgroundShadow: LNPopupEnvironmentNullableConsumer<NSShadow>?
	@Entry var popupBarFloatingBackgroundCornerConfiguration: LNPopupEnvironmentConsumer<Any?>?
	@Entry var popupBarImageShadow: LNPopupEnvironmentNullableConsumer<NSShadow>?
	@Entry var popupBarTitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	@Entry var popupBarSubtitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	@Entry var popupBarCustomBarView: LNPopupEnvironmentConsumer<LNPopupBarCustomView>?
	@Entry var popupBarContextMenu: LNPopupEnvironmentConsumer<AnyView>?
	@Entry var popupBarCustomizer: LNPopupEnvironmentConsumer<((LNPopupBar) -> Void)>?
	@Entry var popupContentViewCustomizer: LNPopupEnvironmentConsumer<((LNPopupContentView) -> Void)>?
	@Entry var popupBarCustomBarPrefersFullBarWidth: LNPopupEnvironmentConsumer<Bool>?
	@Entry var popupBarMinimizationEnabled: LNPopupEnvironmentConsumer<Bool>?
}

internal func UIImageOrientationToImageOrientation(_ o: UIImage.Orientation) -> Image.Orientation {
	switch o {
	case .up:
		return .up
	case .down:
		return .down
	case .left:
		return .left
	case .right:
		return .right
	case .upMirrored:
		return .upMirrored
	case .downMirrored:
		return .downMirrored
	case .leftMirrored:
		return .leftMirrored
	case .rightMirrored:
		return .rightMirrored
	@unknown default:
		return Image.Orientation(rawValue: UInt8(o.rawValue))!
	}
}
