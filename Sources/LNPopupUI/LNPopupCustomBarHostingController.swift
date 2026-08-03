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

/// An object that manages a custom SwiftUI popup bar view hierarchy.
public class LNPopupCustomBarHostingController<CustomBarContent: View> : LNPopupCustomBarViewController {
	/// A UIKit custom popup bar controller that manages a SwiftUI view hierarchy.
	///
	/// Create a `LNPopupCustomBarHostingController` object when you want to integrate SwiftUI popup content into a UIKit view hierarchy.
	///
	/// - Parameter content: The root view of the SwiftUI view hierarchy that you want to manage using the custom popup bar controller.
	public required init(content: CustomBarContent) {
		self.content = content
		hostingChild = UIHostingController(rootView: LNPopupCustomBarHostingController.anyViewIgnoring(self.content))
		
		super.init(nibName: nil, bundle: nil)
		
		addChild(hostingChild)
		if #available(iOS 16.4, *) {
			hostingChild.safeAreaRegions = []
		}
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
	
	/// A UIKit custom popup bar controller that manages a SwiftUI view hierarchy.
	///
	/// Create a `LNPopupCustomBarHostingController` object when you want to integrate SwiftUI popup content into a UIKit view hierarchy.
	///
	/// - Parameter content: The root view of the SwiftUI view hierarchy that you want to manage using the custom popup bar controller.
	public convenience init(@ViewBuilder content: () -> CustomBarContent) {
		self.init(content: content())
	}
	
	/// Indicates whether the default tap gesture recognizer should be added to the popup bar.
	///
	/// Override this property to replace the value.
	///
	/// Defaults to `true`.
	@MainActor public override var wantsDefaultTapGestureRecognizer: Bool {
		return _wantsDefaultTapGestureRecognizer
	}
	
	/// Indicates whether the default pan gesture recognizer should be added to the popup bar.
	///
	/// Override this property to replace the value.
	///
	/// Defaults to `true`.
	@MainActor public override var wantsDefaultPanGestureRecognizer: Bool {
		return _wantsDefaultPanGestureRecognizer
	}
	
	/// Indicates whether the default highlight gesture recognizer should be added to the popup bar.
	///
	/// Override this property to replace the value.
	///
	/// Defaults to `true`.
	@MainActor public override var wantsDefaultHighlightGestureRecognizer: Bool {
		return _wantsDefaultHighlightGestureRecognizer
	}
	
	/// The safe area regions that this custom bar view controller adds to its view.
	///
	/// The default value is `[]`.
	@available(iOS 16.4, *)
	@MainActor public var safeAreaRegions: SafeAreaRegions {
		get {
			hostingChild.safeAreaRegions
		}
		set {
			hostingChild.safeAreaRegions = newValue
		}
	}
	
	/// The custom bar content.
	@MainActor public var content: CustomBarContent {
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
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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
	
	fileprivate class func anyViewIgnoring(_ anyView: CustomBarContent) -> AnyView {
		let anyViewIgnoring: AnyView
		if #available(iOS 16.4, *) {
			//Handled through hostingChild.safeAreaRegions = []
			anyViewIgnoring = AnyView(anyView)
		} else {
			anyViewIgnoring = AnyView(erasing: anyView.ignoresSafeArea(.all))
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
	
	deinit {
		NotificationCenter.default.removeObserver(keyboardObserver1!)
		NotificationCenter.default.removeObserver(keyboardObserver2!)
	}
}
