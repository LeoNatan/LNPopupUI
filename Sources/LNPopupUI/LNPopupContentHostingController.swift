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

public class LNPopupContentHostingController<PopupContent: View> : UIHostingController<AnyView>, LNPopupBarDataSource, LNPopupBarDelegate {
	/// A UIKit popup content controller that manages a SwiftUI view hierarchy.
	///
	/// Create a `LNPopupContentHostingController` object when you want to integrate SwiftUI popup content into a UIKit view hierarchy.
	///
	/// - Parameter content: The root view of the SwiftUI view hierarchy that you want to manage using the popup content controller.
	public required
	init(content: PopupContent) {
		self.popupContentRootView = content
		super.init(rootView: AnyView(EmptyView()))
		rootView = transform(self.popupContentRootView)
	}
	
	/// A UIKit popup content controller that manages a SwiftUI view hierarchy.
	///
	/// Create a `LNPopupContentHostingController` object when you want to integrate SwiftUI popup content into a UIKit view hierarchy.
	///
	/// - Parameter content: The root view of the SwiftUI view hierarchy that you want to manage using the popup content controller.
	public convenience
	init(@ViewBuilder content: () -> PopupContent) {
		self.init(content: content())
	}
	
	/// The popup content root view of the SwiftUI view hierarchy managed by this popup content controller.
	@MainActor public
	var popupContentRootView: PopupContent {
		didSet {
			rootView = transform(popupContentRootView)
		}
	}
	
	public override
	func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updateContentBackgroundColor()
		
		let viewToLimitInteractionTo = interactionContainerSubview() ?? super.viewForPopupInteractionGestureRecognizer
		interactionLimitRect = view.convert(viewToLimitInteractionTo.bounds, from: viewToLimitInteractionTo)
	}
	
	@objc(_ln_interactionLimitRect) private
	var interactionLimitRect: CGRect = .zero
	
	internal
	var userContentBackgroundColor: UIColor? = nil
	
	internal
	var popupItemData: LNPopupItemData? = nil
	
	public
	func popupBar(_ popupBar: LNPopupBar, popupItemBefore popupItem: LNPopupItem) -> LNPopupItem? {
		popupItemBefore(for: popupBar)
	}
	
	public
	func popupBar(_ popupBar: LNPopupBar, popupItemAfter popupItem: LNPopupItem) -> LNPopupItem? {
		popupItemAfter(for: popupBar)
	}
	
	public
	func popupBar(_ popupBar: LNPopupBar, didDisplay newPopupItem: LNPopupItem, previous previousPopupItem: LNPopupItem?) {
		updatePopupItemSelection(newPopupItem)
	}
	
	internal
	var backgroundViewForTransitionViewLookup: UIView? = nil
	internal
	var foregroundViewForTransitionViewLookup: UIView? = nil
	
	@objc(_ln_transitionViewForPopupTransitionFromPresentationState:toPresentationState:view:) internal
	func transitionViewForPopupTransition(from fromState: UIViewController.PopupPresentationState, to toState: UIViewController.PopupPresentationState, view outView: UnsafeMutablePointer<LNPopupTransitionView>) -> UIView? {
		guard #available(iOS 26, *) else {
			return viewBasedTransitionViewForPopupTransition(from: fromState, to: toState, view: outView)
		}
		
		return layerBasedTransitionViewForPopupTransition(from: fromState, to: toState, view: outView)
	}
	
	required dynamic
	init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
