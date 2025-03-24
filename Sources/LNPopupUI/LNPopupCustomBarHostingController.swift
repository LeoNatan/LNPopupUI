//
//  LNPopupCustomBarHostingController.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-09-04.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import UIKit
import LNPopupController

public class LNPopupCustomBarHostingController<CustomBarContent: View> : LNPopupCustomBarViewController {
	@objc(_ln_popupUIRequiresZeroInsets) let popupUIRequiresZeroInsets = true
	
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
	
	public override var wantsDefaultTapGestureRecognizer: Bool {
		return _wantsDefaultTapGestureRecognizer
	}
	
	public override var wantsDefaultPanGestureRecognizer: Bool {
		return _wantsDefaultPanGestureRecognizer
	}
	
	public override var wantsDefaultHighlightGestureRecognizer: Bool {
		return _wantsDefaultHighlightGestureRecognizer
	}
	
	fileprivate class func anyViewIgnoring(_ anyView: CustomBarContent) -> AnyView {
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
		
		size.height = fittingSize.height
		
		if preferredContentSize != size {
			preferredContentSize = size
		}
	}
	
	var content: CustomBarContent {
		didSet {
			hostingChild.rootView = LNPopupCustomBarHostingController.anyViewIgnoring(content)
			
			hostingChild.view.setNeedsLayout()
			hostingChild.view.layoutIfNeeded()
			updatePreferredContentSize()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updatePreferredContentSize()
	}
	
	public required init(@ViewBuilder content: @escaping () -> CustomBarContent) {
		let content = content()
		self.content = content
		hostingChild = UIHostingController(rootView: LNPopupCustomBarHostingController.anyViewIgnoring(content))
		
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
			Task { @MainActor in
				self.ignoringSizeChangesDueToKeyboardNonsense = true
			}
		}
		keyboardObserver2 = NotificationCenter.default.addObserver(forName: UIApplication.keyboardDidHideNotification, object: nil, queue: nil) { [unowned self] notification in
			Task { @MainActor in
				self.ignoringSizeChangesDueToKeyboardNonsense = false
			}
		}
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(keyboardObserver1!)
		NotificationCenter.default.removeObserver(keyboardObserver2!)
	}
}
