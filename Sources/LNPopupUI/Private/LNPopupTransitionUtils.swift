//
//  LNPopupTransitionUtils.swift
//  LNPopupUI
//
//  Created by Léo Natan on 28/3/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import ObjectiveC

internal class LNPopupUITransitionHelperView : UIView {
	enum HelperType {
		case background
		case foreground
	}
	
	let helperType: HelperType
	
	init(_ helperType: HelperType) {
		self.helperType = helperType
		
		super.init(frame: .zero)
		
		switch helperType {
		case .background:
			backgroundColor = .clear
		case .foreground:
			backgroundColor = .clear
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
		guard helperType == .background, let ancestorVC = self.value(forKey: ancestorKey) as? LNPopupContentHostingControllerTransitionSupport else {
			return
		}
		
		ancestorVC.viewForTransitionViewLookup = self
	}
	
	override var intrinsicContentSize: CGSize {
		return subviews.first?.intrinsicContentSize ?? CGSize(width: -1.0, height: -1.0)
	}
}

fileprivate var ancestorKey: String = {
	//viewControllerForAncestor
	let b64d = "dmlld0NvbnRyb2xsZXJGb3JBbmNlc3Rvcg==".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return str
}()

internal struct LNPopupUITransitionBackground: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		return LNPopupUITransitionHelperView(.background)
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

internal struct LNPopupUITransitionForeground: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		return LNPopupUITransitionHelperView(.foreground)
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

internal class LNPopupUITransitionHelper: NSObject, LNPopupTransitionView {
	var originalMasksToBoundsValues: [Bool] = []
	var viewsForCornerRadius: [UIView]? {
		var viewToUse = self.sourceView
		
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
			objc_setAssociatedObject($0.layer, &shouldIgnoreCornerAndShadowsSet, true, .OBJC_ASSOCIATION_RETAIN)
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
			objc_setAssociatedObject(sourceView.layer, &shouldIgnoreCornerAndShadowsSet, true, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	@objc(_transitionDidEnd)
	func transitionDidEnd() {
		viewsForCornerRadius?.forEach { objc_setAssociatedObject($0.layer, &shouldIgnoreCornerAndShadowsSet, nil, .OBJC_ASSOCIATION_RETAIN) }
		viewsForCornerRadius?.enumerated().forEach { $1.layer.masksToBounds = originalMasksToBoundsValues[$0] }
		if sourceView._isInheritedView {
			objc_setAssociatedObject(sourceView.layer, &shouldIgnoreCornerAndShadowsSet, nil, .OBJC_ASSOCIATION_RETAIN)
			sourceView.layer.shadowOpacity = origShadowOpacity
		}
	}
	
	let sourceView: UIView
	
	init(sourceView: UIView) {
		swizzleCALayer()
		
		self.sourceView = sourceView
		
		super.init()
	}
}

fileprivate var shouldIgnoreCornerAndShadowsSet: UInt8 = 0

fileprivate
var swizzleCALayer: () -> Void = {
	let cls = CALayer.self
	
	let setMasksToBoundsSel = #selector(setter: CALayer.masksToBounds)
	let setMasksToBoundsM = class_getInstanceMethod(cls, setMasksToBoundsSel)!
	let setMasksToBoundsImp = method_getImplementation(setMasksToBoundsM)
	let setMasksToBoundsOrig = unsafeBitCast(setMasksToBoundsImp, to: (@convention(c) (CALayer?, Selector, Bool) -> Void).self)
	let setMasksToBoundsNewImp: @convention(block) (CALayer, Bool) -> Void = { layer, masksToBounds in
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSet) as? Bool == true {
			return
		}
		setMasksToBoundsOrig(layer, setMasksToBoundsSel, masksToBounds)
	}
	method_setImplementation(setMasksToBoundsM, imp_implementationWithBlock(setMasksToBoundsNewImp))
	
	let setCornerRadiusSel = #selector(setter: CALayer.cornerRadius)
	let setCornerRadiusM = class_getInstanceMethod(cls, setCornerRadiusSel)!
	let setCornerRadiusImp = method_getImplementation(setCornerRadiusM)
	let setCornerRadiusOrig = unsafeBitCast(setCornerRadiusImp, to: (@convention(c) (CALayer?, Selector, CGFloat) -> Void).self)
	let setCornerRadiusNewImp: @convention(block) (CALayer, CGFloat) -> Void = { layer, cornerRadius in
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSet) as? Bool == true {
			return
		}
		setCornerRadiusOrig(layer, setCornerRadiusSel, cornerRadius)
	}
	method_setImplementation(setCornerRadiusM, imp_implementationWithBlock(setCornerRadiusNewImp))
	
	let setShadowOpacitySel = #selector(setter: CALayer.shadowOpacity)
	let setShadowOpacityM = class_getInstanceMethod(cls, setShadowOpacitySel)!
	let setShadowOpacityImp = method_getImplementation(setShadowOpacityM)
	let setShadowOpacityOrig = unsafeBitCast(setShadowOpacityImp, to: (@convention(c) (CALayer?, Selector, Float) -> Void).self)
	let setShadowOpacityNewImp: @convention(block) (CALayer, Float) -> Void = { layer, shadowOpacity in
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSet) as? Bool == true {
			return
		}
		setShadowOpacityOrig(layer, setShadowOpacitySel, shadowOpacity)
	}
	method_setImplementation(setShadowOpacityM, imp_implementationWithBlock(setShadowOpacityNewImp))
	
	return {}
}()

internal
protocol LNPopupContentHostingControllerTransitionSupport: AnyObject {
	var viewForTransitionViewLookup: UIView? { get set }
}

internal
extension LNPopupContentHostingController {
	fileprivate
	func findTransitionView() -> UIView? {
		guard let viewForTransitionViewLookup else {
			return nil
		}
		
		guard var superview = viewForTransitionViewLookup.superview,
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
		
		return targetView
	}
	
	func private_transitionViewForPopupTransition(from fromState: UIViewController.PopupPresentationState, to toState: UIViewController.PopupPresentationState, view outView: UnsafeMutablePointer<LNPopupTransitionView>) -> UIView? {
		guard let viewForTransition = findTransitionView(),
			  let cls = NSClassFromString("_LNPopupTransitionView") as Any as? NSObjectProtocol else {
			return nil
		}
		
		let transitionView = cls.perform(Selector(("transitionViewWithSourceView:")), with: viewForTransition).takeUnretainedValue() as? UIView
		
		outView.pointee = LNPopupUITransitionHelper(sourceView: viewForTransition)
		
		return transitionView
	}
}

extension LNPopupContentHostingController: LNPopupContentHostingControllerTransitionSupport {
	
}
