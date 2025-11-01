//
//  LNPopupContentHostingController+Private.swift
//  LNPopupUI
//
//  Created by Léo Natan on 20/9/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

extension LNPopupContentHostingController {	
	func updateOrSetPopupItem(_ popupItem: TypeErasedPopupItem?, in popupBar: LNPopupBar) {
		guard let popupItem else {
			popupBar.popupItem = LNPopupItem()
			return
		}
		
		if let oldPopupItem = popupBar.popupItem {
			popupItem.update(oldPopupItem, popupBar: popupBar)
		} else {
			popupBar.popupItem = popupItem.lnPopupItem(for: popupBar)
		}
	}
	
	internal
	func transform(_ popupContentRootView: PopupContent) -> AnyView {
		return AnyView(popupContentRootView.onPreferenceChange(LNPopupItemsPreferenceKey.self) { [weak self] popupItemsWrapper in
			guard let self, let popupItemsWrapper else {
				return
			}
			
			guard let container = self.popupPresentationContainer else {
				fatalError()
			}
			
			if let popupItemData = popupItemsWrapper.value {
				container.popupBar.usesContentControllersAsDataSource = false
				container.popupBar.dataSource = self
				container.popupBar.delegate = self
				self.popupItemData = popupItemData
				
				updateOrSetPopupItem(popupItemData.selectedPopupItem(), in: container.popupBar)
			} else {
				container.popupBar.dataSource = nil
				container.popupBar.delegate = nil
				container.popupBar.usesContentControllersAsDataSource = true
			}
		}.onPreferenceChange(LNPopupItemPreferenceKey.self) { [weak self] popupItemWrapper in
			guard let self, let popupItemWrapper else {
				return
			}
			
			guard let container = self.popupPresentationContainer else {
				fatalError()
			}
			
			container.popupBar.dataSource = nil
			container.popupBar.delegate = nil
			
			container.popupBar.usesContentControllersAsDataSource = false
			updateOrSetPopupItem(popupItemWrapper.value, in: container.popupBar)			
		}.onPreferenceChange(LNPopupTitlePreferenceKey.self) { [weak self] titleDataWrapper in
			guard let titleDataWrapper else {
				return
			}
			
			self?.popupItem.title = titleDataWrapper.value?.title
			self?.popupItem.subtitle = titleDataWrapper.value?.subtitle
		}.onPreferenceChange(LNPopupTextTitlePreferenceKey.self) { [weak self] titleDataWrapper in
			guard let titleDataWrapper, let self = self else {
				return
			}
			
			createOrUpdateTitleAdapter(in: self.popupItem, for: titleDataWrapper.value, popupBar: self.popupBar)
		}.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] imageSettingsWrapper in
			guard let self, let imageSettingsWrapper else {
				return
			}
			
			createOrUpdateImageAdapter(in: self.popupItem, for: imageSettingsWrapper.value)
		}.onPreferenceChange(LNPopupProgressPreferenceKey.self) { [weak self] progressWrapper in
			guard let progressWrapper else {
				return
			}
			
			self?.popupItem.progress = progressWrapper.value!
		}.onPreferenceChange(LNPopupLeadingBarItemsPreferenceKey.self) { [weak self] viewCreatorWrapper in
			guard let self, let viewCreatorWrapper else {
				return
			}
			
			//Async so that the navigation controller is created in a different transaction
			DispatchQueue.main.async {
				let anyView = viewCreatorWrapper.value
				createOrUpdateBarItemAdapter(in: self.popupItem, key: "swiftuiHiddenLeadingController", buttonKeyPath: \.leadingBarButtonItems, userNavigationViewWrapper: anyView)
			}
		}.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] viewCreatorWrapper in
			guard let self, let viewCreatorWrapper else {
				return
			}
			
			//Async so that the navigation controller is created in a different transaction
			DispatchQueue.main.async {
				let anyView = viewCreatorWrapper.value
				createOrUpdateBarItemAdapter(in: self.popupItem, key: "swiftuiHiddenTrailingController", buttonKeyPath: \.trailingBarButtonItems, userNavigationViewWrapper: anyView)
			}
		}.onPreferenceChange(LNPopupContentBackgroundColorPreferenceKey.self, perform: { [weak self] colorWrapper in
			guard let colorWrapper else {
				return
			}
			
			self?.userContentBackgroundColor = colorWrapper.value
			self?.updateContentBackgroundColor()
		}))
	}
	
	func updateContentBackgroundColor() {
		view.backgroundColor = userContentBackgroundColor ?? .clear
	}
	
	private class func firstSubview<T: UIView>(of view: UIView, ofType: T.Type) -> T? {
		if let view = view as? T {
			return view
		}
		
		var rv: T? = nil
		
		for subview in view.subviews {
			let candidate = firstSubview(of: subview, ofType: T.self)
			if let candidate = candidate {
				rv = candidate
				break
			}
		}
		
		return rv
	}
	
	internal func interactionContainerSubview() -> UIView? {
		return LNPopupContentHostingController.firstSubview(of: view, ofType: LNPopupUIInteractionContainerView.self)
	}
}

extension LNPopupContentHostingController {
	func popupItemBefore(for popupBar: LNPopupBar) -> LNPopupItem? {
		guard let popupItemData, let idx = popupItemData.popupItems.firstIndex(where: { popupItem in
			popupItem.anyId == popupItemData.selection.wrappedValue
		}) else {
			return nil
		}
		
		if idx == 0 {
			return nil
		}
		
		let item = popupItemData.popupItems[idx - 1].lnPopupItem(for: popupBar)
		item.barButtonItems = popupBar.popupItem?.barButtonItems
		return item
	}
	
	func popupItemAfter(for popupBar: LNPopupBar) -> LNPopupItem? {
		guard let popupItemData, let idx = popupItemData.popupItems.firstIndex(where: { popupItem in
			popupItem.anyId == popupItemData.selection.wrappedValue
		}) else {
			return nil
		}
		
		if idx == popupItemData.popupItems.count - 1 {
			return nil
		}
		
		let item = popupItemData.popupItems[idx + 1].lnPopupItem(for: popupBar)
		item.barButtonItems = popupBar.popupItem?.barButtonItems
		return item
	}
	
	func updatePopupItemSelection(_ lnPopupItem: LNPopupItem) {
		let rv: AnyHashable = anyhashableID(from: lnPopupItem)!
		popupItemData?.selection.wrappedValue = rv
	}
}
