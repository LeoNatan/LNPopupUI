//
//  File.swift
//  
//
//  Created by Leo Natan (Wix) on 9/3/20.
//

import SwiftUI
import UIKit
import LNPopupController

internal class LNPopupUICustomPopupBarController : LNPopupCustomBarViewController {
	fileprivate let hostingChild: UIHostingController<AnyView>
	var _wantsDefaultTapGestureRecognizer: Bool = true
	var _wantsDefaultPanGestureRecognizer: Bool = true
	var _wantsDefaultHighlightGestureRecognizer: Bool = true
	
	override var wantsDefaultTapGestureRecognizer: Bool {
		return _wantsDefaultTapGestureRecognizer
	}
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		return _wantsDefaultPanGestureRecognizer
	}
	
	override var wantsDefaultHighlightGestureRecognizer: Bool {
		return _wantsDefaultHighlightGestureRecognizer
	}
	
	func setAnyView(_ anyView: AnyView) {
		hostingChild.rootView = anyView
		
		hostingChild.view.layoutIfNeeded()
		self.preferredContentSize = hostingChild.sizeThatFits(in: CGSize.zero)
	}
	
	required init(anyView: AnyView) {
		hostingChild = UIHostingController(rootView: anyView)
		
		super.init(nibName: nil, bundle: nil)
		
		addChild(hostingChild)
		hostingChild.view.backgroundColor = nil
		hostingChild.view.translatesAutoresizingMaskIntoConstraints = true
		hostingChild.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		hostingChild.view.frame = view.bounds
		view.addSubview(hostingChild.view)
		hostingChild.didMove(toParent: self)
		
		hostingChild.view.layoutIfNeeded()
		self.preferredContentSize = hostingChild.sizeThatFits(in: CGSize.zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
