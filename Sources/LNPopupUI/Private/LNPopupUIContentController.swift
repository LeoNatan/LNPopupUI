//
//  LNPopupUIContentController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//  
//

import SwiftUI
import UIKit

internal class LNPopupUIContentController<Content> : UIHostingController<AnyView> where Content: View {
	@objc var _ln_interactionLimitRect: CGRect = .zero
	
	internal class LNPopupBarTitleViewAdapter: UIHostingController<TitleContentView> {
		@objc(_ln_popupUIRequiresZeroInsets) var popupUIRequiresZeroInsets: Bool {
			true
		}
	}
	
	internal class LNPopupBarItemAdapter: UIHostingController<AnyView> {
		let updater: ([UIBarButtonItem]?) -> Void
		var doneUpdating = false
		
		@objc(_ln_popupUIRequiresZeroInsets) let popupUIRequiresZeroInsets = true
		
		@objc var overrideSizeClass: UIUserInterfaceSizeClass = .regular {
			didSet {
				self.setValue(UITraitCollection(verticalSizeClass: overrideSizeClass), forKey: "overrideTraitCollection")
			}
		}
		
		required init(rootView: AnyView, updater: @escaping ([UIBarButtonItem]?) -> Void) {
			self.updater = updater
			
			super.init(rootView: rootView)
			
			self.setValue(UITraitCollection(verticalSizeClass: overrideSizeClass), forKey: "overrideTraitCollection")
		}
		
		required dynamic init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func addChild(_ childController: UIViewController) {
			super.addChild(childController)
		}
		
		override func viewDidLayoutSubviews() {
			super.viewDidLayoutSubviews()
			
			let nav = self.children.first as! UINavigationController
			self.updater(nav.toolbar.items)
		}
	}
	
	internal struct TitleContentView : View {
		@Environment(\.sizeCategory) var sizeCategory
		@Environment(\.colorScheme) var colorScheme
		
		let titleView: AnyView
		let subtitleView: AnyView?
		let popupBar: LNPopupBar
		
		init(titleView: AnyView, subtitleView: AnyView?, popupBar: LNPopupBar) {
			self.titleView = titleView
			self.subtitleView = subtitleView
			self.popupBar = popupBar
		}
		
		var body: some View {
			let titleFont = popupBar.value(forKey: "_titleFont") as! CTFont
			let subtitleFont = popupBar.value(forKey: "_subtitleFont") as! CTFont
			let titleColor = popupBar.value(forKey: "_titleColor") as! UIColor
			let subtitleColor = popupBar.value(forKey: "_subtitleColor") as! UIColor
			
			VStack(spacing: 2) {
				titleView.font(Font(titleFont)).foregroundColor(Color(titleColor))
				subtitleView.font(Font(subtitleFont)).foregroundColor(Color(subtitleColor))
			}.lineLimit(1)
		}
	}
	
	@ViewBuilder func titleContentView(fromTitleView titleView: AnyView, subtitleView: AnyView?, target: UIViewController) -> TitleContentView {
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
	
	var leadingBarItemsController: LNPopupBarItemAdapter? = nil
	var trailingBarItemsController: LNPopupBarItemAdapter? = nil
	
	fileprivate func transform(_ popupContentRootView: Content) -> AnyView {
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
			}
			.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] image in
				if let imageController = self?.popupItem.value(forKey: "swiftuiImageController") as? LNPopupBarImageAdapter {
					imageController.rootView = image
				} else {
					self?.popupItem.setValue(image != nil ? LNPopupBarImageAdapter(rootView: image) : nil, forKey: "swiftuiImageController")
				}
			}
			.onPreferenceChange(LNPopupProgressPreferenceKey.self) { [weak self] progress in
				self?.popupItem.progress = progress ?? 0.0
			}
			.onPreferenceChange(LNPopupLeadingBarItemsPreferenceKey.self) { [weak self] view in
				if let self = self, let anyView = view?.anyView {
					self.createOrUpdateBarItemAdapter(&self.leadingBarItemsController, userNavigationViewWrapper: anyView) { [weak self] in self?.popupItem.leadingBarButtonItems = $0
					}
					popupItem.setValue(self.leadingBarItemsController!, forKey: "swiftuiHiddenLeadingController")
				}
			}
			.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] view in
				if let self = self, let anyView = view?.anyView {
					self.createOrUpdateBarItemAdapter(&self.trailingBarItemsController, userNavigationViewWrapper: anyView) { [weak self] in
						self?.popupItem.trailingBarButtonItems = $0
					}
					popupItem.setValue(self.trailingBarItemsController!, forKey: "swiftuiHiddenTrailingController")
				}
			})
	}
	
	required init(popupContentRootView: Content) {
		self.popupContentRootView = popupContentRootView
		super.init(rootView: AnyView(EmptyView()))
		rootView = transform(popupContentRootView)
	}
	
	var popupContentRootView: Content {
		didSet {
			rootView = transform(popupContentRootView)
		}
	}
	
	required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
	
	private func interactionContainerSubview() -> UIView? {
		return LNPopupUIContentController.firstSubview(of: view, ofType: LNPopupUIInteractionContainerView.self)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewToLimitInteractionTo = interactionContainerSubview() ?? super.viewForPopupInteractionGestureRecognizer
		_ln_interactionLimitRect = view.convert(viewToLimitInteractionTo.bounds, from: viewToLimitInteractionTo)
	}
}
