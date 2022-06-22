//
//  LNPopupEnvironment.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import LNPopupController

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
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupInteractionStyle>? = nil
}

internal struct LNPopupBarStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBarStyle>? = nil
}

internal struct LNPopupCloseButtonStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupCloseButtonStyle>? = nil
}

internal struct LNPopupBarProgressViewStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBarProgressViewStyle>? = nil
}

internal struct LNPopupBarMarqueeScrollEnabledKey: EnvironmentKey {
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

internal struct LNPopupBarBackgroundEffectKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<UIBlurEffect>? = nil
}

internal struct LNPopupBarCustomViewKey: EnvironmentKey {
	static let defaultValue: LNPopupEnvironmentConsumer<LNPopupBarCustomView>? = nil
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
	var popupInteractionStyle: LNPopupEnvironmentConsumer<LNPopupInteractionStyle>? {
		get { self[LNPopupInteractionStyleKey.self] }
		set { self[LNPopupInteractionStyleKey.self] = newValue }
	}
	
	var popupCloseButtonStyle: LNPopupEnvironmentConsumer<LNPopupCloseButtonStyle>? {
		get { self[LNPopupCloseButtonStyleKey.self] }
		set { self[LNPopupCloseButtonStyleKey.self] = newValue }
	}
	
	var popupBarStyle: LNPopupEnvironmentConsumer<LNPopupBarStyle>? {
		get { self[LNPopupBarStyleKey.self] }
		set { self[LNPopupBarStyleKey.self] = newValue }
	}
	
	var popupBarProgressViewStyle: LNPopupEnvironmentConsumer<LNPopupBarProgressViewStyle>? {
		get { self[LNPopupBarProgressViewStyleKey.self] }
		set { self[LNPopupBarProgressViewStyleKey.self] = newValue }
	}
	
	var popupBarMarqueeScrollEnabled: LNPopupEnvironmentConsumer<Bool>? {
		get { self[LNPopupBarMarqueeScrollEnabledKey.self] }
		set { self[LNPopupBarMarqueeScrollEnabledKey.self] = newValue }
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
	
	var popupBarBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>? {
		get { self[LNPopupBarBackgroundEffectKey.self] }
		set { self[LNPopupBarBackgroundEffectKey.self] = newValue }
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
