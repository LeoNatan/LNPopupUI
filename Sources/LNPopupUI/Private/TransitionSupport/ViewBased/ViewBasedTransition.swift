//
//  ViewBasedTransition.swift
//  LNPopupUI
//
//  Created by Léo Natan on 20/9/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

fileprivate let inheritedNameContainment: String = {
	//InheritedView
	let b64d = "SW5oZXJpdGVkVmlldw==".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return str
}()

fileprivate
extension UIView {
	var _isInheritedView: Bool {
		NSStringFromClass(type(of: self)).contains(inheritedNameContainment)
	}
}

@available(iOS, obsoleted: 26.0) internal
class LNPopupUIViewTransitionHelper: NSObject, LNPopupTransitionView {
	let isContainer: Bool
	var originalMasksToBoundsValues: [Bool] = []
	var viewsForCornerRadius: [UIView]? {
		var viewToUse = self.sourceView
		
		if isContainer {
			return [viewToUse]
		}
		
		while viewToUse.subviews.count <= 1 {
			guard let subview = viewToUse.subviews.first else {
				break
			}
			
			viewToUse = subview
		}
		
		return viewToUse.subviews.count > 0 ? viewToUse.subviews : [viewToUse]
	}
	
	var cornerRadius: CGFloat {
		get {
			viewsForCornerRadius?.first?.layer.cornerRadius ?? 0.0
		}
		set {
			viewsForCornerRadius?.forEach { $0.layer.cornerRadius = newValue }
		}
	}
	
	var origShadowOpacity: Float = 0.0
	var shadow: NSShadow? {
		get {
			nil
		}
		set {}
	}
	
	var supportsShadow: Bool {
		false
	}
	
	@objc(_transitionWillBeginToState:)
	func transitionWillBegin(to state: UIViewController.PopupPresentationState) {
		originalMasksToBoundsValues = viewsForCornerRadius?.map { $0.layer.masksToBounds } ?? []
		viewsForCornerRadius?.forEach {
			$0.layer.masksToBounds = true
			objc_setAssociatedObject($0.layer, &shouldIgnoreCornerAndShadowsSetKey, true, .OBJC_ASSOCIATION_RETAIN)
		}
		if sourceView._isInheritedView {
			origShadowOpacity = sourceView.layer.shadowOpacity
			if state == .open {
				UIView.performWithoutAnimation {
					sourceView.layer.shadowOpacity = 0.0
				}
				sourceView.layer.shadowOpacity = origShadowOpacity
			} else {
				sourceView.layer.shadowOpacity = 0.0
			}
			objc_setAssociatedObject(sourceView.layer, &shouldIgnoreCornerAndShadowsSetKey, true, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	@objc(_transitionDidEnd)
	func transitionDidEnd() {
		viewsForCornerRadius?.forEach { objc_setAssociatedObject($0.layer, &shouldIgnoreCornerAndShadowsSetKey, nil, .OBJC_ASSOCIATION_RETAIN) }
		viewsForCornerRadius?.enumerated().forEach { $1.layer.masksToBounds = originalMasksToBoundsValues[$0] }
		if sourceView._isInheritedView {
			objc_setAssociatedObject(sourceView.layer, &shouldIgnoreCornerAndShadowsSetKey, nil, .OBJC_ASSOCIATION_RETAIN)
			sourceView.layer.shadowOpacity = origShadowOpacity
		}
	}
	
	let sourceView: UIView
	
	init(sourceView: UIView, isContainer: Bool) {
		swizzleCALayer()
		
		self.sourceView = sourceView
		self.isContainer = isContainer
		
		super.init()
	}
}

extension LNPopupContentHostingController {
	@available(iOS, obsoleted: 26.0)
	func viewBasedTransitionViewForPopupTransition(from fromState: UIViewController.PopupPresentationState, to toState: UIViewController.PopupPresentationState, view outView: UnsafeMutablePointer<LNPopupTransitionView>) -> UIView? {
		guard let (viewForTransition, isContainer) = findTransitionView(),
			  let cls = NSClassFromString("_LNPopupTransitionView") as Any as? NSObjectProtocol else {
			return nil
		}
		
		let transitionView = cls.perform(Selector(("transitionViewWithSourceView:")), with: viewForTransition).takeUnretainedValue() as? UIView
		
		outView.pointee = LNPopupUIViewTransitionHelper(sourceView: viewForTransition, isContainer: isContainer)
		
		return transitionView
	}
	
	@available(iOS, obsoleted: 26.0)
	fileprivate
	func findTransitionView() -> (UIView, Bool)? {
		guard let backgroundViewForTransitionViewLookup else {
			return nil
		}
		
		guard var backgroundWrapper = backgroundViewForTransitionViewLookup.superview,
			  var backgroundContainer = backgroundWrapper.superview else {
			return nil
		}
		
		while backgroundContainer.subviews.count <= 1 {
			guard let backgroundContainerSuperview = backgroundContainer.superview else {
				return nil
			}
			
			backgroundWrapper = backgroundContainer
			backgroundContainer = backgroundContainerSuperview
		}
		
		if let foregroundWrapper = foregroundViewForTransitionViewLookup?.superview, let foregroundContainer = foregroundWrapper.superview, backgroundContainer == foregroundContainer, backgroundContainer.subviews.first == backgroundWrapper, backgroundContainer.subviews.last == foregroundWrapper {
			return (backgroundContainer, true)
		}
		
		var targetView: UIView
		if backgroundContainer._isInheritedView {
			targetView = backgroundContainer
		} else {
			guard let idx = backgroundContainer.subviews.firstIndex(of: backgroundWrapper), backgroundContainer.subviews.count > idx + 1 else {
				return nil
			}
			targetView = backgroundContainer.subviews[idx + 1]
		}
		
		while let superview = targetView.superview, superview._isInheritedView {
			targetView = superview
		}
		
		return (targetView, false)
	}
}
