//
//  LNPopupTransitionUtils.swift
//  LNPopupUI
//
//  Created by Léo Natan on 28/3/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import ObjectiveC

private
class LNPopupUITransitionHelperView : UIView {
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
	
	required
	init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override
	func didMoveToWindow() {
		super.didMoveToWindow()
		
		guard let ancestorVC = self.value(forKey: ancestorKey) as? LNPopupContentHostingControllerTransitionSupport else {
			return
		}
		
		switch helperType {
		case .background:
			ancestorVC.backgroundViewForTransitionViewLookup = self
		case .foreground:
			ancestorVC.foregroundViewForTransitionViewLookup = self
		}
	}
	
	override var intrinsicContentSize: CGSize {
		return subviews.first?.intrinsicContentSize ?? CGSize(width: -1.0, height: -1.0)
	}
}

fileprivate
var ancestorKey: String = {
	//viewControllerForAncestor
	let b64d = "dmlld0NvbnRyb2xsZXJGb3JBbmNlc3Rvcg==".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return str
}()

internal
struct LNPopupUITransitionBackground: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		return LNPopupUITransitionHelperView(.background)
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

internal
struct LNPopupUITransitionForeground: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		return LNPopupUITransitionHelperView(.foreground)
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

internal
var shouldIgnoreCornerAndShadowsSetKey: UInt8 = 0

internal
var swizzleCALayer: () -> Void = {
	let cls = CALayer.self
	
	let setMasksToBoundsSel = #selector(setter: CALayer.masksToBounds)
	let setMasksToBoundsM = class_getInstanceMethod(cls, setMasksToBoundsSel)!
	let setMasksToBoundsImp = method_getImplementation(setMasksToBoundsM)
	let setMasksToBoundsOrig = unsafeBitCast(setMasksToBoundsImp, to: (@convention(c) (CALayer?, Selector, Bool) -> Void).self)
	let setMasksToBoundsNewImp: @convention(block) (CALayer, Bool) -> Void = { layer, masksToBounds in
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSetKey) as? Bool == true {
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
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSetKey) as? Bool == true {
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
		if objc_getAssociatedObject(layer, &shouldIgnoreCornerAndShadowsSetKey) as? Bool == true {
			return
		}
		setShadowOpacityOrig(layer, setShadowOpacitySel, shadowOpacity)
	}
	method_setImplementation(setShadowOpacityM, imp_implementationWithBlock(setShadowOpacityNewImp))
	
	return {}
}()

internal
protocol LNPopupContentHostingControllerTransitionSupport: AnyObject {
	var backgroundViewForTransitionViewLookup: UIView? { get set }
	var foregroundViewForTransitionViewLookup: UIView? { get set }
}

extension LNPopupContentHostingController: LNPopupContentHostingControllerTransitionSupport { }
