//
//  LNPopupContentHostingController.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//
//

import SwiftUI
import UIKit

public class LNPopupContentHostingController<PopupContent> : UIHostingController<AnyView> where PopupContent: View {
	@objc var _ln_interactionLimitRect: CGRect = .zero
	
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
	
	fileprivate
	var leadingBarItemsController: LNPopupBarItemAdapter? = nil
	fileprivate
	var trailingBarItemsController: LNPopupBarItemAdapter? = nil
	
	var userContentBackgroundColor: UIColor? = nil
	
	fileprivate func transform(_ popupContentRootView: PopupContent) -> AnyView {
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
					self.createOrUpdateBarItemAdapter(&self.leadingBarItemsController, userNavigationViewWrapper: anyView) { [weak self] in self?.popupItem.leadingBarButtonItems = $0
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
	
	public required init(@ViewBuilder content: () -> PopupContent) {
		self.popupContentRootView = content()
		super.init(rootView: AnyView(EmptyView()))
		rootView = transform(self.popupContentRootView)
	}
	
	public var popupContentRootView: PopupContent {
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
		return LNPopupContentHostingController.firstSubview(of: view, ofType: LNPopupUIInteractionContainerView.self)
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updateContentBackgroundColor()
		
		let viewToLimitInteractionTo = interactionContainerSubview() ?? super.viewForPopupInteractionGestureRecognizer
		_ln_interactionLimitRect = view.convert(viewToLimitInteractionTo.bounds, from: viewToLimitInteractionTo)
	}
	
	internal
	var backgroundViewForTransitionViewLookup: UIView? = nil
	internal
	var foregroundViewForTransitionViewLookup: UIView? = nil
	
	@objc(_ln_transitionViewForPopupTransitionFromPresentationState:toPresentationState:view:)
	fileprivate
	func transitionViewForPopupTransition(from fromState: UIViewController.PopupPresentationState, to toState: UIViewController.PopupPresentationState, view outView: UnsafeMutablePointer<LNPopupTransitionView>) -> UIView? {
		guard let (viewForTransition, isContainer) = findTransitionView(),
			  let cls = NSClassFromString("_LNPopupTransitionView") as Any as? NSObjectProtocol else {
			return nil
		}
		
		let transitionView = cls.perform(Selector(("transitionViewWithSourceView:")), with: viewForTransition).takeUnretainedValue() as? UIView
		
		outView.pointee = LNPopupUITransitionHelper(sourceView: viewForTransition, isContainer: isContainer)
		
		return transitionView
	}
	
	fileprivate
	func findTransitionView() -> (UIView, Bool)? {
		guard let backgroundViewForTransitionViewLookup else {
			return nil
		}
		
		guard var superview = backgroundViewForTransitionViewLookup.superview,
			  var supersuperview = superview.superview else {
			return nil
		}
		
		while supersuperview.subviews.count <= 1 {
			guard let sssv = supersuperview.superview else {
				return nil
			}
			
			superview = supersuperview
			supersuperview = sssv
		}
		
		if let foregroundSuperview = foregroundViewForTransitionViewLookup?.superview, let foregroundSupersuperview = foregroundSuperview.superview, supersuperview == foregroundSupersuperview, supersuperview.subviews.first == superview, supersuperview.subviews.last == foregroundSuperview {
			return (supersuperview, true)
		}
		
		var targetView: UIView
		if supersuperview._isInheritedView {
			targetView = supersuperview
		} else {
			guard let idx = supersuperview.subviews.firstIndex(of: superview), supersuperview.subviews.count > idx + 1 else {
				return nil
			}
			targetView = supersuperview.subviews[idx + 1]
		}
		
		while let superview = targetView.superview, superview._isInheritedView {
			targetView = superview
		}
		
		return (targetView, false)
	}
}

internal
protocol LNPopupContentHostingControllerTransitionSupport: AnyObject {
	var backgroundViewForTransitionViewLookup: UIView? { get set }
	var foregroundViewForTransitionViewLookup: UIView? { get set }
}

extension LNPopupContentHostingController: LNPopupContentHostingControllerTransitionSupport { }
