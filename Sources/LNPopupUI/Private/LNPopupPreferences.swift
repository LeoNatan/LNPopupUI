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

internal struct LNPopupTitleData : Equatable {
	let title: String
	let subtitle: String?
}

internal struct LNPopupTitleContentData {
	let titleView: AnyView
	let subtitleView: AnyView?
}

internal struct LNPopupImageData: Equatable {
	let image: Image
	let resizable: Bool
	let aspectRatio: CGFloat?
	let contentMode: ContentMode
	
	init?(image: Image?, resizable: Bool, aspectRatio: CGFloat?, contentMode: ContentMode) {
		guard let image else { return nil }
		self.image = image
		self.resizable = resizable
		self.aspectRatio = aspectRatio
		self.contentMode = contentMode
	}
}

internal
struct LNPopupItemData {
	let selection: Binding<AnyHashable>
	let popupItems: [any PopupItemProtocol & ToAnyHashable]
	
	func selectedPopupItem() -> TypeErasedPopupItem? {
		if let item = popupItems.first(where: { $0.anyId == selection.wrappedValue }) {
			return item.toAnyHashable()
		} else {
			let directPopupItem = popupItems.first?.toAnyHashable()
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
	typealias Value = LNPopupPreferenceValue<LNPopupTitleData>?
}

internal struct LNPopupTextTitlePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<LNPopupTitleContentData>?
}

internal struct LNPopupProgressPreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<Float>?
}

internal struct LNPopupImagePreferenceKey: LNPopupNullablePreferenceKey {
	typealias Value = LNPopupPreferenceValue<LNPopupImageData>?
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
