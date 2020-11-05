//
//  LNPopupEnvironment.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import LNPopupController

internal struct LNPopupInteractionStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupInteractionStyle = .default
}

internal struct LNPopupBarStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupBarStyle = .default
}

internal struct LNPopupCloseButtonStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupCloseButtonStyle = .default
}

internal struct LNPopupBarProgressViewStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupBarProgressViewStyle = .default
}

internal struct LNPopupBarMarqueeScrollEnabledKey: EnvironmentKey {
	static let defaultValue: Bool = false
}

internal struct LNPopupBarCustomViewKey: EnvironmentKey {
	static let defaultValue: LNPopupBarCustomView? = nil
}

internal struct LNPopupBarContextMenuKey: EnvironmentKey {
	static let defaultValue: AnyView? = nil
}

internal extension EnvironmentValues {
	var popupInteractionStyle: LNPopupInteractionStyle {
		get { self[LNPopupInteractionStyleKey.self] }
		set { self[LNPopupInteractionStyleKey.self] = newValue }
	}
	
	var popupCloseButtonStyle: LNPopupCloseButtonStyle {
		get { self[LNPopupCloseButtonStyleKey.self] }
		set { self[LNPopupCloseButtonStyleKey.self] = newValue }
	}
	
	var popupBarStyle: LNPopupBarStyle {
		get { self[LNPopupBarStyleKey.self] }
		set { self[LNPopupBarStyleKey.self] = newValue }
	}
	
	var popupBarProgressViewStyle: LNPopupBarProgressViewStyle {
		get { self[LNPopupBarProgressViewStyleKey.self] }
		set { self[LNPopupBarProgressViewStyleKey.self] = newValue }
	}
	
	var popupBarMarqueeScrollEnabled: Bool {
		get { self[LNPopupBarMarqueeScrollEnabledKey.self] }
		set { self[LNPopupBarMarqueeScrollEnabledKey.self] = newValue }
	}
	
	var popupBarCustomBarView: LNPopupBarCustomView? {
		get { self[LNPopupBarCustomViewKey.self] }
		set { self[LNPopupBarCustomViewKey.self] = newValue }
	}
	
	var popupBarContextMenu: AnyView? {
		get { self[LNPopupBarContextMenuKey.self] }
		set { self[LNPopupBarContextMenuKey.self] = newValue }
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
