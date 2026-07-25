//
//  PopItem+Private.swift
//  LNPopupUI
//
//  Created by Léo Natan on 28/10/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNSwiftUIUtils

internal
class TitleContainer<TitleContent, SubtitleContent> {
	let titleContent: TitleContent
	let subtitleContent: SubtitleContent?
	
	init(_ titleContent: TitleContent, _ subtitleContent: SubtitleContent?) {
		self.titleContent = titleContent
		self.subtitleContent = subtitleContent
	}
	
	var description: String {
		"title: “\(titleContent)”\(subtitleContent != nil ? "subtitle: “\(subtitleContent!)”" : "")"
	}
	
	dynamic
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		fatalError("Unsupported type")
	}
	
	dynamic
	func eq(rhs: TitleContainer) -> Bool {
		false
	}
}

internal
class StringTitleContainer: TitleContainer<String, String> {
	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		popupItem.title = titleContent
		popupItem.subtitle = subtitleContent
	}
	
	override
	func eq(rhs: TitleContainer<String, String>) -> Bool {
		return titleContent == rhs.titleContent && subtitleContent == rhs.subtitleContent
	}
}

@available(iOS 15, *) internal
class AttributedStringTitleContainer: TitleContainer<AttributedString, AttributedString> {
	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		popupItem.attributedTitle = titleContent.swiftUIToUIKit
		popupItem.attributedSubtitle = subtitleContent?.swiftUIToUIKit
	}
	
	override
	func eq(rhs: TitleContainer<AttributedString, AttributedString>) -> Bool {
		return titleContent == rhs.titleContent && subtitleContent == rhs.subtitleContent
	}
}

internal
class ViewTitleContainer<TitleContent: View, SubtitleContent: View>: TitleContainer<TitleContent, SubtitleContent> {
	override
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		let subtitleView: AnyView
		if let subtitleContent {
			subtitleView = AnyView(subtitleContent)
		} else {
			subtitleView = AnyView(EmptyView())
		}
		let titleView = TitleContentView(titleView: AnyView(titleContent), subtitleView: subtitleView, popupBar: popupBar)
		createOrUpdateTitleAdapter(in: popupItem, for: titleView)
	}
}

internal
class EquatableViewTitleContainer<TitleContent: View & Equatable, SubtitleContent: View & Equatable>: ViewTitleContainer<TitleContent, SubtitleContent> {
	override
	func eq(rhs: TitleContainer<TitleContent, SubtitleContent>) -> Bool {
		titleContent == rhs.titleContent && subtitleContent == rhs.subtitleContent
	}
}

internal
struct ButtonContainer<LeadingContent: ToolbarContent, TrailingContent: ToolbarContent> {
	let leadingContent: LeadingContent?
	let trailingContent: TrailingContent?
	
	func update(_ popupItem: LNPopupItem, for popupBar: LNPopupBar) {
		let leadingView = leadingContent.map { barItemContainer($0) }
		createOrUpdateBarItemAdapter(in: popupItem, key: "swiftuiHiddenLeadingController", buttonKeyPath: \.leadingBarButtonItems, userNavigationViewWrapper: leadingView, for: popupBar)
		let trailingView = trailingContent.map { barItemContainer($0) }
		createOrUpdateBarItemAdapter(in: popupItem, key: "swiftuiHiddenTrailingController", buttonKeyPath: \.trailingBarButtonItems, userNavigationViewWrapper: trailingView, for: popupBar)
	}
	
	func eq(rhs: ButtonContainer) -> Bool {
		false
	}
}

extension ButtonContainer where LeadingContent == Never {
	init(trailingContent: TrailingContent) {
		leadingContent = nil
		self.trailingContent = trailingContent
	}
}

extension ButtonContainer where TrailingContent == Never {
	init(leadingContent: LeadingContent) {
		self.leadingContent = leadingContent
		trailingContent = nil
	}
}

extension ButtonContainer where LeadingContent == Never, TrailingContent == Never {
	init() {
		leadingContent = nil
		trailingContent = nil
	}
}

@usableFromInline internal
func emptyToolbarItem() -> some ToolbarContent {
	ToolbarItem(placement: .popupBar) {}
}

fileprivate let userInfoKey = "_lnpopup_ui_identifier"

extension PopupItem {
	internal
	init(id: Identifier, titleContainer: TitleContainer<TitleContent, SubtitleContent>, image: PopupItemImageType?, leadingButtons: LeadingButtonToolbarContent, trailingButtons: TrailingButtonToolbarContent, progress: Float?, private: Void) {
		self.init(id: id, titleContainer: titleContainer, image: image, buttonContainer: ButtonContainer(leadingContent: leadingButtons, trailingContent: trailingButtons), progress: progress, private: `private`)
	}
	
	internal
	init(id: Identifier, titleContainer: TitleContainer<TitleContent, SubtitleContent>, image: PopupItemImageType?, buttonContainer: ButtonContainer<LeadingButtonToolbarContent, TrailingButtonToolbarContent>, progress: Float?, private: Void) {
		self.id = id
		self.titleContainer = titleContainer
		self.image = image
		self.buttonContainer = buttonContainer
		self.progress = progress
	}
	
	internal
	func toAnyHashable() -> PopupItem<AnyHashable, TitleContent, SubtitleContent, LeadingButtonToolbarContent, TrailingButtonToolbarContent> {
		PopupItem<AnyHashable, TitleContent, SubtitleContent, LeadingButtonToolbarContent, TrailingButtonToolbarContent>(id: AnyHashable(id), titleContainer: titleContainer, image: image, buttonContainer: buttonContainer, progress: progress, private: ())
	}
	
	internal
	func imageAdapter(for imageSettings: LNPopupImageData) -> LNPopupBarImageAdapter {
		let contentMode = imageSettings.contentMode
		var image = imageSettings.image
		if imageSettings.resizable {
			image = image.resizable()
		}
		let view = AnyView(image.aspectRatio(imageSettings.aspectRatio, contentMode: contentMode))
		
		let imageController = LNPopupBarImageAdapter(rootView: view)
		imageController.contentMode = contentMode
		imageController.aspectRatio = imageSettings.aspectRatio
		
		return imageController
	}
	
	internal
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
	
	internal
	func lnPopupItem(for popupBar: LNPopupBar) -> LNPopupItem {
		let rv = LNPopupItem()
		update(rv, popupBar: popupBar)
		return rv
	}
}

extension PopupItem where LeadingButtonToolbarContent == Never {
	internal
	init(id: Identifier, titleContainer: TitleContainer<TitleContent, SubtitleContent>, image: PopupItemImageType?, buttons: TrailingButtonToolbarContent, progress: Float?, private: Void) {
		self.init(id: id, titleContainer: titleContainer, image: image, buttonContainer: ButtonContainer(trailingContent: buttons), progress: progress, private: `private`)
	}
}

extension PopupItem where LeadingButtonToolbarContent == Never, TrailingButtonToolbarContent == Never {
	internal
	init(id: Identifier, titleContainer: TitleContainer<TitleContent, SubtitleContent>, image: PopupItemImageType?, buttons: TrailingButtonToolbarContent, progress: Float?, private: Void) {
		self.init(id: id, titleContainer: titleContainer, image: image, buttonContainer: ButtonContainer(), progress: progress, private: `private`)
	}
}

internal
protocol PopupItemProtocol<Identifier> {
	associatedtype Identifier: Hashable
	var id: Identifier { get }
	func lnPopupItem(for popupBar: LNPopupBar) -> LNPopupItem
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar)
}

extension PopupItem: PopupItemProtocol {}

extension AnyPopupItem {
	internal
	func lnPopupItem(for popupBar: LNPopupBar) -> LNPopupItem {
		base.lnPopupItem(for: popupBar)
	}
	
	internal
	func update(_ popupItem: LNPopupItem, popupBar: LNPopupBar) {
		base.update(popupItem, popupBar: popupBar)
	}
}

internal
func anyhashableID(from lnPopupItem: LNPopupItem) -> AnyHashable? {
	lnPopupItem.userInfo?[userInfoKey] as? AnyHashable
}

typealias TypeErasedPopupItem = AnyPopupItem<AnyHashable>

internal
protocol ToAnyHashable {
	var anyId: AnyHashable { get }
	var toAnyHashable: () -> AnyPopupItem<AnyHashable> { get }
}

extension AnyPopupItem: ToAnyHashable, PopupItemProtocol {}

internal
extension Array<any ToAnyHashable> {
	subscript(any index: Index) -> Element {
		self[index].toAnyHashable()
	}
}
