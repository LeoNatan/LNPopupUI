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
	@objc(_ln_interactionLimitRect) private
	var interactionLimitRect: CGRect = .zero
	
	internal
	var userContentBackgroundColor: UIColor? = nil
	
	public required
	init(@ViewBuilder content: () -> PopupContent) {
		self.popupContentRootView = content()
		super.init(rootView: AnyView(EmptyView()))
		rootView = transform(self.popupContentRootView)
	}
	
	public
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
