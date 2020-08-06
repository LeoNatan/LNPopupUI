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

internal struct LNPopupBarProgressViewStyleKey: EnvironmentKey {
	static let defaultValue: LNPopupBarProgressViewStyle = .default
}

internal struct LNPopupBarMarqueeScrollEnabledKey: EnvironmentKey {
	static let defaultValue: Bool = false
}

internal extension EnvironmentValues {
	var popupInteractionStyle: LNPopupInteractionStyle {
		get { self[LNPopupInteractionStyleKey.self] }
		set { self[LNPopupInteractionStyleKey.self] = newValue }
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
}
