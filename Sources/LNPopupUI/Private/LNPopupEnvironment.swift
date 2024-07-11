//
//  LNPopupEnvironment.swift
//  LNPopupUI
//
//  Created by Léo Natan on 8/6/20.
//

import SwiftUI
import LNPopupController

@MainActor
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

internal struct LNPopupInteractionStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<UIViewController.PopupInteractionStyle>? = nil
}

internal struct LNPopupBarStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBar.Style>? = nil
}

internal struct LNPopupCloseButtonStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupCloseButton.Style>? = nil
}

internal struct LNPopupBarProgressViewStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBar.ProgressViewStyle>? = nil
}

internal struct LNPopupBarMarqueeScrollEnabledKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupHapticFeedbackEnabledKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupBarMarqueeRateKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<CGFloat>? = nil
}

internal struct LNPopupBarMarqueeDelayKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<TimeInterval>? = nil
}

internal struct LNPopupBarCoordinateMarqueeAnimationsKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupBarShouldExtendPopupBarUnderSafeAreaKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupBarInheritsAppearanceFromDockingView: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupBarInheritsEnvironmentFont: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Bool>? = nil
}

internal struct LNPopupBarBackgroundEffectKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<UIBlurEffect>? = nil
}

internal struct LNPopupBarFloatingBackgroundEffectKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<UIBlurEffect>? = nil
}

internal struct LNPopupBarCustomViewKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBarCustomView>? = nil
}

internal struct LNPopupBarFloatingBackgroundShadowKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<NSShadow>? = nil
}

internal struct LNPopupBarImageShadowKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<NSShadow>? = nil
}

internal struct LNPopupBarTitleTextAttributesKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Any>? = nil
}

internal struct LNPopupBarSubtitleTextAttributesKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<Any>? = nil
}

internal struct LNPopupBarContextMenuKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<AnyView>? = nil
}

internal struct LNPopupBarCustomizer: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<((LNPopupBar) -> Void)>? = nil
}

internal struct LNPopupContentViewCustomizer: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<((LNPopupContentView) -> Void)>? = nil
}

internal extension EnvironmentValues {
	var popupInteractionStyle: LNPopupEnvironmentConsumer<UIViewController.PopupInteractionStyle>? {
		get { self[LNPopupInteractionStyleKey.self] }
		set { self[LNPopupInteractionStyleKey.self] = newValue }
	}
	
	var popupCloseButtonStyle: LNPopupEnvironmentConsumer<LNPopupCloseButton.Style>? {
		get { self[LNPopupCloseButtonStyleKey.self] }
		set { self[LNPopupCloseButtonStyleKey.self] = newValue }
	}
	
	var popupBarStyle: LNPopupEnvironmentConsumer<LNPopupBar.Style>? {
		get { self[LNPopupBarStyleKey.self] }
		set { self[LNPopupBarStyleKey.self] = newValue }
	}
	
	var popupBarProgressViewStyle: LNPopupEnvironmentConsumer<LNPopupBar.ProgressViewStyle>? {
		get { self[LNPopupBarProgressViewStyleKey.self] }
		set { self[LNPopupBarProgressViewStyleKey.self] = newValue }
	}
	
	var popupBarMarqueeScrollEnabled: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarMarqueeScrollEnabledKey.self] }
		set { self[LNPopupBarMarqueeScrollEnabledKey.self] = newValue }
	}
	
	var popupHapticFeedbackEnabled: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupHapticFeedbackEnabledKey.self] }
		set { self[LNPopupHapticFeedbackEnabledKey.self] = newValue }
	}
	
	var popupBarMarqueeRate: LNPopupEnvironmentConsumer<CGFloat>? {
		get { self[LNPopupBarMarqueeRateKey.self] }
		set { self[LNPopupBarMarqueeRateKey.self] = newValue }
	}
	
	var popupBarMarqueeDelay: LNPopupEnvironmentConsumer<TimeInterval>? {
		get { self[LNPopupBarMarqueeDelayKey.self] }
		set { self[LNPopupBarMarqueeDelayKey.self] = newValue }
	}
	
	var popupBarCoordinateMarqueeAnimations: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarCoordinateMarqueeAnimationsKey.self] }
		set { self[LNPopupBarCoordinateMarqueeAnimationsKey.self] = newValue }
	}
	
	var popupBarShouldExtendPopupBarUnderSafeArea: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarShouldExtendPopupBarUnderSafeAreaKey.self] }
		set { self[LNPopupBarShouldExtendPopupBarUnderSafeAreaKey.self] = newValue }
	}
	
	var popupBarInheritsAppearanceFromDockingView: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarInheritsAppearanceFromDockingView.self] }
		set { self[LNPopupBarInheritsAppearanceFromDockingView.self] = newValue }
	}
	
	var popupBarInheritsEnvironmentFont: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarInheritsEnvironmentFont.self] }
		set { self[LNPopupBarInheritsEnvironmentFont.self] = newValue }
	}
	
	var popupBarBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>? {
		get { self[LNPopupBarBackgroundEffectKey.self] }
		set { self[LNPopupBarBackgroundEffectKey.self] = newValue }
	}
	
	var popupBarFloatingBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>? {
		get { self[LNPopupBarFloatingBackgroundEffectKey.self] }
		set { self[LNPopupBarFloatingBackgroundEffectKey.self] = newValue }
	}
	
	var popupBarFloatingBackgroundShadow: LNPopupEnvironmentConsumer<NSShadow>? {
		get { self[LNPopupBarFloatingBackgroundShadowKey.self] }
		set { self[LNPopupBarFloatingBackgroundShadowKey.self] = newValue }
	}
	
	var popupBarImageShadow: LNPopupEnvironmentConsumer<NSShadow>? {
		get { self[LNPopupBarImageShadowKey.self] }
		set { self[LNPopupBarImageShadowKey.self] = newValue }
	}
	
	var popupBarTitleTextAttributes: LNPopupEnvironmentConsumer<Any>? {
		get { self[LNPopupBarTitleTextAttributesKey.self] }
		set { self[LNPopupBarTitleTextAttributesKey.self] = newValue }
	}
	
	var popupBarSubtitleTextAttributes: LNPopupEnvironmentConsumer<Any>? {
		get { self[LNPopupBarSubtitleTextAttributesKey.self] }
		set { self[LNPopupBarSubtitleTextAttributesKey.self] = newValue }
	}
	
	var popupBarCustomBarView: LNPopupEnvironmentConsumer<LNPopupBarCustomView>? {
		get { self[LNPopupBarCustomViewKey.self] }
		set { self[LNPopupBarCustomViewKey.self] = newValue }
	}
	
	var popupBarContextMenu: LNPopupEnvironmentConsumer<AnyView>? {
		get { self[LNPopupBarContextMenuKey.self] }
		set { self[LNPopupBarContextMenuKey.self] = newValue }
	}
	
	var popupBarCustomizer: LNPopupEnvironmentConsumer<((LNPopupBar) -> Void)>? {
		get { self[LNPopupBarCustomizer.self] }
		set { self[LNPopupBarCustomizer.self] = newValue }
	}
	
	var popupContentViewCustomizer: LNPopupEnvironmentConsumer<((LNPopupContentView) -> Void)>? {
		get { self[LNPopupContentViewCustomizer.self] }
		set { self[LNPopupContentViewCustomizer.self] = newValue }
	}
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
