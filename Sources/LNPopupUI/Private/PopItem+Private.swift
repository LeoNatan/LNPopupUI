//
//  PopItem+Private.swift
//  LNPopupUI
//
//  Created by Léo Natan on 28/10/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNSwiftUIUtils

// MARK: - Title Containers


internal
func makeButtonContainer<Trailing: ToolbarContent>(buttons: Trailing) -> ButtonContainer {
    ButtonContainer(trailingView: barItemContainer(buttons))
}

internal
func makeButtonContainer<Leading: ToolbarContent, Trailing: ToolbarContent>(leadingButtons: Leading, trailingButtons: Trailing) -> ButtonContainer {
    let leadingView: AnyView? = Leading.self == EmptyPopupToolbarContent.self ? nil : barItemContainer(leadingButtons)
    let trailingView: AnyView? = Trailing.self == EmptyPopupToolbarContent.self ? nil : barItemContainer(trailingButtons)
    return ButtonContainer(leadingView: leadingView, trailingView: trailingView)
}

internal
class TitleContainer {
	dynamic
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		fatalError("Unsupported type")
	}
}

internal
class StringTitleContainer: TitleContainer {
	let title: String
	let subtitle: String?

	init(_ title: String, _ subtitle: String?) {
		self.title = title
		self.subtitle = subtitle
	}

	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		popupItem.title = title
		popupItem.subtitle = subtitle
	}
}

@available(iOS 15, *) internal
class AttributedStringTitleContainer: TitleContainer {
	let title: AttributedString
	let subtitle: AttributedString?

	init(_ title: AttributedString, _ subtitle: AttributedString?) {
		self.title = title
		self.subtitle = subtitle
	}

	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		popupItem.attributedTitle = title.swiftUIToUIKit
		popupItem.attributedSubtitle = subtitle?.swiftUIToUIKit
	}
}

internal
class ViewTitleContainer: TitleContainer {
	let titleView: AnyView
	let subtitleView: AnyView

	init(titleView: AnyView, subtitleView: AnyView) {
		self.titleView = titleView
		self.subtitleView = subtitleView
	}

	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		let titleView = TitleContentView(titleView: titleView, subtitleView: subtitleView, popupBar: popupBar)
		createOrUpdateTitleAdapter(in: popupItem, for: titleView)
	}
}

// MARK: - Button Container

internal
struct ButtonContainer {
	let leadingView: AnyView?
	let trailingView: AnyView?

	init(leadingView: AnyView? = nil, trailingView: AnyView? = nil) {
		self.leadingView = leadingView
		self.trailingView = trailingView
	}

	func update(_ popupItem: LNPopupItem, for popupBar: LNPopupBar) {
		createOrUpdateBarItemAdapter(in: popupItem, key: "swiftuiHiddenLeadingController", buttonKeyPath: \.leadingBarButtonItems, userNavigationViewWrapper: leadingView, for: popupBar)
		createOrUpdateBarItemAdapter(in: popupItem, key: "swiftuiHiddenTrailingController", buttonKeyPath: \.trailingBarButtonItems, userNavigationViewWrapper: trailingView, for: popupBar)
	}
}

@usableFromInline internal
struct EmptyPopupToolbarContent: ToolbarContent {
	@usableFromInline
	nonisolated init() {}

	@usableFromInline
	var body: some ToolbarContent {
		ToolbarItem(placement: .popupBar) {}
	}
}

// MARK: - PopupItem Internals

fileprivate let userInfoKey = "_lnpopup_ui_identifier"

internal
extension PopupItem {
	func eraseToAnyHashableIdentifier() -> TypeErasedPopupItem {
        TypeErasedPopupItem(id: AnyHashable(id), titleContainer: titleContainer, image: image, buttonContainer: buttonContainer, progress: progress)
	}

	var anyId: AnyHashable {
		AnyHashable(id)
	}

	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		popupItem.userInfo = [userInfoKey: id]

		titleContainer.update(popupItem, popupBar: popupBar)

		let imageData: LNPopupImageData?
		if let image = image as? PopupItemImage {
			imageData = LNPopupImageData(image: image.image, resizable: image.resizable, aspectRatio: image.aspectRatio, contentMode: image.contentMode)
		} else if let image = image as? SwiftUI.Image {
			imageData = LNPopupImageData(image: image, resizable: true, aspectRatio: nil, contentMode: .fit)
		} else {
			imageData = nil
		}
		createOrUpdateImageAdapter(in: popupItem, for: imageData)

		buttonContainer.update(popupItem, for: popupBar)

		if let progress {
			popupItem.progress = progress
		}
	}

	func lnPopupItem(for popupBar: LNPopupBar) -> LNPopupItem {
		let rv = LNPopupItem()
		update(rv, popupBar: popupBar)
		return rv
	}
}

typealias TypeErasedPopupItem = PopupItem<AnyHashable>

internal
func anyhashableID(from lnPopupItem: LNPopupItem) -> AnyHashable? {
	lnPopupItem.userInfo?[userInfoKey] as? AnyHashable
}
