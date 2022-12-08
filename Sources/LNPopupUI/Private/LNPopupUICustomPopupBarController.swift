//
//  LNPopupUICustomPopupBarController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 9/3/20.
//

import SwiftUI
import UIKit
import LNPopupController

internal class LNPopupUICustomPopupBarController : LNPopupCustomBarViewController {
	fileprivate let hostingChild: UIHostingController<AnyView>
	var _wantsDefaultTapGestureRecognizer: Bool = true
	var _wantsDefaultPanGestureRecognizer: Bool = true
	var _wantsDefaultHighlightGestureRecognizer: Bool = true
	
	var ignoringSizeChangesDueToKeyboardNonsense = false {
		didSet {
			UIView.animate(withDuration: 0.2) {
				self.updatePreferredContentSize()
			}
		}
	}
	var keyboardObserver1: Any!
	var keyboardObserver2: Any!
	
	override var wantsDefaultTapGestureRecognizer: Bool {
		return _wantsDefaultTapGestureRecognizer
	}
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		return _wantsDefaultPanGestureRecognizer
	}
	
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return _wantsDefaultHighlightGestureRecognizer
	}
	
	fileprivate class func anyViewIgnoring(_ anyView: AnyView) -> AnyView {
		let anyViewIgnoring: AnyView
		if #available(iOS 14, *) {
			anyViewIgnoring = AnyView(erasing: anyView.ignoresSafeArea(.keyboard))
		} else {
			anyViewIgnoring = AnyView(erasing: anyView.edgesIgnoringSafeArea(.all))
		}
		return anyViewIgnoring
	}
	
	fileprivate func updatePreferredContentSize() {
		guard ignoringSizeChangesDueToKeyboardNonsense == false else {
			return
		}
		
		var size = CGSize.zero
		if let containingPopupBar = containingPopupBar {
			size.width = containingPopupBar.frame.size.width
		}
		
		let fittingSize = hostingChild.sizeThatFits(in: size)
		
		if preferredContentSize != fittingSize {
			preferredContentSize = fittingSize
		}
	}
	
	func setAnyView(_ anyView: AnyView) {
		hostingChild.rootView = LNPopupUICustomPopupBarController.anyViewIgnoring(anyView)
		
		hostingChild.view.setNeedsLayout()
		hostingChild.view.layoutIfNeeded()
		updatePreferredContentSize()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updatePreferredContentSize()
	}
	
	required init(anyView: AnyView) {
		hostingChild = UIHostingController(rootView: LNPopupUICustomPopupBarController.anyViewIgnoring(anyView))
		
		super.init(nibName: nil, bundle: nil)
		
		addChild(hostingChild)
		hostingChild.view.backgroundColor = nil
		hostingChild.view.translatesAutoresizingMaskIntoConstraints = true
		hostingChild.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		hostingChild.view.frame = view.bounds
		view.addSubview(hostingChild.view)
		hostingChild.didMove(toParent: self)
		
		hostingChild.view.layoutIfNeeded()
		updatePreferredContentSize()
		
		//These hacks are necessary to avoid bugs where the SwiftUI layout system reports an incorrect size when the keyboard is open. See https://github.com/LeoNatan/LNPopupUI/issues/11
		keyboardObserver1 = NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [unowned self] notification in
			self.ignoringSizeChangesDueToKeyboardNonsense = true
		}
		keyboardObserver2 = NotificationCenter.default.addObserver(forName: UIApplication.keyboardDidHideNotification, object: nil, queue: nil) { [unowned self] notification in
			self.ignoringSizeChangesDueToKeyboardNonsense = false
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

  deinit {
    NotificationCenter.default.removeObserver(keyboardObserver1!)
    NotificationCenter.default.removeObserver(keyboardObserver2!)
  }
}
