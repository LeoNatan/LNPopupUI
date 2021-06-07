//
//  LNPopupPreferences.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//  

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupTitleData : Equatable {
	let title: String
	let subtitle: String?
}

internal struct LNPopupAnyViewWrapper : Equatable {
	let anyView: AnyView
	
	static func == (lhs: LNPopupAnyViewWrapper, rhs: LNPopupAnyViewWrapper) -> Bool {
		return false
	}
}

internal struct LNPopupWantsInteractionContainerKey: LNPopupNullablePreferenceKey {
	typealias Value = Bool?
}

internal struct LNPopupTitlePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupTitleData?
}

internal struct LNPopupProgressPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = Float?
}

internal struct LNPopupImagePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = Image?
}

internal struct LNPopupLeadingBarItemsPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupAnyViewWrapper?
}

internal struct LNPopupTrailingBarItemsPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupAnyViewWrapper?
}

internal protocol LNPopupNullablePreferenceKey : PreferenceKey {
	static var defaultValue: Value? {
		get
	}
}

internal extension LNPopupNullablePreferenceKey {
	static var defaultValue: Value? {
		get {
			return nil
		}
	}
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value = nextValue()
	}
}
