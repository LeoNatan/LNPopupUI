//
//  LNPopupContentHostingController+Private.swift
//  LNPopupUI
//
//  Created by Léo Natan on 20/9/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

extension LNPopupContentHostingController {
	internal
	func transform(_ popupContentRootView: PopupContent) -> AnyView {
		return AnyView(popupContentRootView.onPreferenceChange(LNPopupItemPreferenceKey.self) { [weak self] popupItemWrapper in
			guard let self, let popupItemWrapper else {
				return
			}
			
			guard let container = self.popupPresentationContainer else {
				fatalError()
			}
			
			if let directPopupItem = popupItemWrapper.value {
				container.popupBar.usesContentControllersAsDataSource = false
				if let popupItem = container.popupBar.popupItem, directPopupItem.isUpdatable(popupItem) {
					directPopupItem.update(popupItem, popupBar: container.popupBar)
				} else {
					container.popupBar.popupItem = directPopupItem.lnPopupItem(for: container.popupBar)
				}
			} else {
				container.popupBar.usesContentControllersAsDataSource = true
			}
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
				let anyView = viewCreatorWrapper.value?.creator().anyView
				createOrUpdateBarItemAdapter(in: self.popupItem, key: "swiftuiHiddenLeadingController", buttonKeyPath: \.leadingBarButtonItems, userNavigationViewWrapper: anyView)
			}
		}.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] viewCreatorWrapper in
			guard let self, let viewCreatorWrapper else {
				return
			}
			
			//Async so that the navigation controller is created in a different transaction
			DispatchQueue.main.async {
				let anyView = viewCreatorWrapper.value?.creator().anyView
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
