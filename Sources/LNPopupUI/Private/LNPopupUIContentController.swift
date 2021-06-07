//
//  LNPopupUIContentController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//  
//

import SwiftUI
import UIKit

internal class LNPopupUIContentController<Content> : UIHostingController<Content> where Content: View {
	@objc var wantsInteractionContainerLookup: Bool = false
	
	private class func firstSubview<T: UIView>(of view: UIView, ofType: T.Type) -> T? {
		
		if let view = view as? T {
			print(view.value(forKey: "recursiveDescription") ?? "")
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
	
	override var viewForPopupInteractionGestureRecognizer: UIView {
		guard wantsInteractionContainerLookup == true else {
			return super.viewForPopupInteractionGestureRecognizer
		}
		
		return interactionContainerSubview() ?? super.viewForPopupInteractionGestureRecognizer
	}
}
