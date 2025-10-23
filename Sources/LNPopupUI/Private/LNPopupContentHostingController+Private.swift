//
//  LNPopupContentHostingController+Private.swift
//  LNPopupUI
//
//  Created by Léo Natan on 20/9/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

extension LNPopupContentHostingController {
	@ViewBuilder
	fileprivate func titleContentView(fromTitleView titleView: AnyView, subtitleView: AnyView?, target: UIViewController) -> TitleContentView {
		TitleContentView(titleView: titleView, subtitleView: subtitleView, popupBar: target.popupBar)
	}
	
	@available(iOS 14.0, *)
	fileprivate func createOrUpdateBarItemAdapter(_ vc: inout LNPopupBarItemAdapter?, userNavigationViewWrapper anyView: AnyView, barButtonUpdater: @escaping ([UIBarButtonItem]?) -> Void) {
		UIView.performWithoutAnimation {
			if let vc = vc {
				vc.rootView = anyView
			} else {
				vc = LNPopupBarItemAdapter(rootView: anyView, updater: barButtonUpdater)
			}
		}
	}
	
	internal
	func transform(_ popupContentRootView: PopupContent) -> AnyView {
		return AnyView(popupContentRootView.onPreferenceChange(LNPopupTitlePreferenceKey.self) { [weak self] titleData in
			self?.popupItem.title = titleData?.title
			self?.popupItem.subtitle = titleData?.subtitle
		}.onPreferenceChange(LNPopupTextTitlePreferenceKey.self) { [weak self] titleData in
			guard let self = self else {
				return
			}
			
			if let titleData = titleData {
				let adapter = LNPopupBarTitleViewAdapter(rootView: titleContentView(fromTitleView: titleData.titleView, subtitleView: titleData.subtitleView, target: self))
				self.popupItem.setValue(adapter.view, forKey: "swiftuiTitleContentView")
			} else {
				self.popupItem.setValue(nil, forKey: "swiftuiTitleContentView")
			}
		}.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] imageSettings in
			guard let imageSettings else {
				self?.popupItem.setValue(nil, forKey: "swiftuiImageController")
				return
			}
			
			let contentMode = imageSettings.contentMode
			var image = imageSettings.image
			if imageSettings.resizable {
				image = image.resizable()
			}
			let view = AnyView(image.aspectRatio(imageSettings.aspectRatio, contentMode: contentMode))
			
			let imageController: LNPopupBarImageAdapter
			if let existing = self?.popupItem.value(forKey: "swiftuiImageController") as? LNPopupBarImageAdapter {
				imageController = existing
				imageController.rootView = view
				
			} else {
				imageController = LNPopupBarImageAdapter(rootView: view)
				self?.popupItem.setValue(imageController, forKey: "swiftuiImageController")
			}
			imageController.contentMode = contentMode
			imageController.aspectRatio = imageSettings.aspectRatio
		}.onPreferenceChange(LNPopupProgressPreferenceKey.self) { [weak self] progress in
			self?.popupItem.progress = progress ?? 0.0
		}.onPreferenceChange(LNPopupLeadingBarItemsPreferenceKey.self) { [weak self] viewCreator in
			//Async so that the navigation controller is created in a different transaction
			DispatchQueue.main.async {
				if let self = self, var anyView = viewCreator?.creator().anyView {
					anyView = AnyView(anyView.accentTintIfNeeded())
					self.createOrUpdateBarItemAdapter(&self.leadingBarItemsController, userNavigationViewWrapper: anyView) { [weak self] in
						self?.popupItem.leadingBarButtonItems = $0
					}
					self.popupItem.setValue(self.leadingBarItemsController!, forKey: "swiftuiHiddenLeadingController")
				}
			}
		}.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] viewCreator in
			//Async so that the navigation controller is created in a different transaction
			DispatchQueue.main.async {
				if let self = self, var anyView = viewCreator?.creator().anyView {
					anyView = AnyView(anyView.accentTintIfNeeded())
					self.createOrUpdateBarItemAdapter(&self.trailingBarItemsController, userNavigationViewWrapper: anyView) { [weak self] in
						self?.popupItem.trailingBarButtonItems = $0
					}
					self.popupItem.setValue(self.trailingBarItemsController!, forKey: "swiftuiHiddenTrailingController")
				}
			}
		}.onPreferenceChange(LNPopupContentBackgroundColorPreferenceKey.self, perform: { [weak self] color in
			self?.userContentBackgroundColor = color
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
