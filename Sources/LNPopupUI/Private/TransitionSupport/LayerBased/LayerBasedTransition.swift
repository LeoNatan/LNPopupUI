//
//  LayerBasedTransition.swift
//  LNPopupUI
//
//  Created by Léo Natan on 20/9/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import os

fileprivate
let logger = {
	Logger(subsystem: "com.LeoNatan.LNPopupUI", category: "Transitions")
}()

@available(iOS 26.0, *) internal
class LNPopupUILayerTransitionHelper: NSObject, LNPopupTransitionView {
	let sourceLayer: CALayer
	
	let shadowLayer: CALayer?
	var origShadowOpacity: Float = 0.0
	
	let cornerRadiusLayers: [CALayer]?
	var originalMasksToBoundsValues: [Bool] = []
	
	init(sourceLayer: CALayer, isFallback: Bool) {
		swizzleCALayer()
		
		self.sourceLayer = sourceLayer
		
		if sourceLayer.masksToBounds == false, sourceLayer.shadowOpacity > 0.0 {
			shadowLayer = sourceLayer
			cornerRadiusLayers = sourceLayer.sublayers
		} else {
			shadowLayer = nil
			cornerRadiusLayers = [sourceLayer]
		}
		
		super.init()
	}
	
	var cornerRadius: CGFloat {
		get {
			cornerRadiusLayers?.first?.cornerRadius ?? 0.0
		}
		set {
			cornerRadiusLayers?.forEach { $0.cornerRadius = newValue }
		}
	}
	
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
		originalMasksToBoundsValues = cornerRadiusLayers?.map { $0.masksToBounds } ?? []
		cornerRadiusLayers?.forEach {
			$0.masksToBounds = true
			objc_setAssociatedObject($0, &shouldIgnoreCornerAndShadowsSetKey, true, .OBJC_ASSOCIATION_RETAIN)
		}
		if let shadowLayer {
			origShadowOpacity = shadowLayer.shadowOpacity
			if state == .open {
				UIView.performWithoutAnimation {
					shadowLayer.shadowOpacity = 0.0
				}
				shadowLayer.shadowOpacity = origShadowOpacity
			} else {
				shadowLayer.shadowOpacity = 0.0
			}
			objc_setAssociatedObject(shadowLayer, &shouldIgnoreCornerAndShadowsSetKey, true, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	@objc(_transitionDidEnd)
	func transitionDidEnd() {
		cornerRadiusLayers?.forEach { objc_setAssociatedObject($0, &shouldIgnoreCornerAndShadowsSetKey, nil, .OBJC_ASSOCIATION_RETAIN) }
		cornerRadiusLayers?.enumerated().forEach { $1.masksToBounds = originalMasksToBoundsValues[$0] }
		if let shadowLayer {
			objc_setAssociatedObject(shadowLayer, &shouldIgnoreCornerAndShadowsSetKey, nil, .OBJC_ASSOCIATION_RETAIN)
			shadowLayer.shadowOpacity = origShadowOpacity
		}
	}
}

extension LNPopupContentHostingController {
	@available(iOS 26.0, *)
	func layerBasedTransitionViewForPopupTransition(from fromState: UIViewController.PopupPresentationState, to toState: UIViewController.PopupPresentationState, view outView: UnsafeMutablePointer<LNPopupTransitionView>) -> UIView? {
		guard let (layerForTransition, isFallback) = findTransitionLayer(),
			  let cls = NSClassFromString("_LNPopupTransitionView") as Any as? NSObjectProtocol else {
			return nil
		}
		
		let transitionView = cls.perform(Selector(("transitionViewWithSourceLayer:")), with: layerForTransition).takeUnretainedValue() as? UIView
		
		outView.pointee = LNPopupUILayerTransitionHelper(sourceLayer: layerForTransition, isFallback: isFallback)
		
		return transitionView
	}
	
	@available(iOS 26.0, *)
	fileprivate
	func findTransitionLayer() -> (CALayer, Bool)? {
		//iOS 26 changes how non-UIViews are handled
		guard let foregroundViewForTransitionViewLookup,
			  let foregroundWrapper = foregroundViewForTransitionViewLookup.superview,
			  let foregroundContainer = foregroundWrapper.superview,
			  let indexOfForeground = foregroundContainer.layer.sublayers?.firstIndex(of: foregroundWrapper.layer) else {
			return nil
		}
		
		if indexOfForeground > 1 {
			logger.warning("Unsupported view for popup transition, results will not be optimal. Consider simplifying your transition target view.")
			return (foregroundContainer.layer, true)
		} else if let layer = foregroundContainer.layer.sublayers?.first {
			return (layer, false)
		}
		
		return nil
	}
}
