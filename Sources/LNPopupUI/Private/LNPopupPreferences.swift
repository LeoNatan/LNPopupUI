//
//  LNPopupPreferences.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import UIKit
import LNPopupController

internal
struct LNPopupItemData {
	let selection: Binding<AnyHashable>
	let popupItems: [TypeErasedPopupItem]

	@MainActor
	func selectedPopupItem() -> TypeErasedPopupItem? {
		if let item = popupItems.first(where: { $0.id == selection.wrappedValue }) {
			return item
		} else {
			let directPopupItem = popupItems.first
			selection.wrappedValue = directPopupItem?.id
			
			return directPopupItem
		}
	}
}

prefix operator %%

#if swift(>=6.0)
@MainActor
#endif
internal
struct LNPopupPreferenceValue<T>: Equatable {
	let value: T?
	
	init(_ value: T?) {
		self.value = value
	}
	
	static
	func == (lhs: LNPopupPreferenceValue<T>, rhs: LNPopupPreferenceValue<T>) -> Bool {
		return false
	}
}

extension LNPopupPreferenceValue where T: Equatable {
	static
	func == (lhs: LNPopupPreferenceValue<T>, rhs: LNPopupPreferenceValue<T>) -> Bool {
		return lhs.value == rhs.value
	}
}

internal
prefix func %%<T>(_ wrapped: T?) -> LNPopupPreferenceValue<T> {
	LNPopupPreferenceValue(wrapped)
}

internal struct LNPopupItemPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<TypeErasedPopupItem>?
}

internal struct LNPopupItemsPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<LNPopupItemData>?
}

internal struct LNPopupTitlePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<StringTitleContainer>?
}

internal struct LNPopupTextTitlePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<ViewTitleContainer>?
}

internal struct LNPopupProgressPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<Float>?
}

internal struct LNPopupImagePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<PopupItemImage>?
}

internal struct LNPopupLeadingBarItemsPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<AnyView>?
}

internal struct LNPopupTrailingBarItemsPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<AnyView>?
}

internal struct LNPopupContentBackgroundColorPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<UIColor>?
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
