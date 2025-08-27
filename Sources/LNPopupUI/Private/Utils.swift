//
//  Utils.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2021-09-20.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import UIKit
import SwiftUI

@objc(__LNPopupUI) fileprivate class __LNPopupUI: NSObject {}

internal class LNPopupBarTitleViewAdapter: UIHostingController<TitleContentView> {
	@objc(_ln_popupUIRequiresZeroInsets) var popupUIRequiresZeroInsets: Bool {
		true
	}
}

internal class LNPopupBarItemAdapter: UIHostingController<AnyView> {
	let updater: ([UIBarButtonItem]?) -> Void
	var doneUpdating = false
	
	@objc(_ln_popupUIRequiresZeroInsets) let popupUIRequiresZeroInsets = true
	
	@objc var overrideSizeClass: UIUserInterfaceSizeClass = .regular {
		didSet {
			self.setValue(UITraitCollection(verticalSizeClass: overrideSizeClass), forKey: "overrideTraitCollection")
		}
	}
	
	required init(rootView: AnyView, updater: @escaping ([UIBarButtonItem]?) -> Void) {
		self.updater = updater
		
		super.init(rootView: rootView)
		
		self.setValue(UITraitCollection(verticalSizeClass: overrideSizeClass), forKey: "overrideTraitCollection")
	}
	
	required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func addChild(_ childController: UIViewController) {
		super.addChild(childController)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let nav = self.children.first as? UINavigationController
		if let nav {
			self.updater(nav.topViewController?.toolbarItems)
		} else {
			print("LNPopupUI: Unexpected layout, please open an issue at https://github.com/LeoNatan/LNPopupUI/issues/new")
		}
	}
}

internal struct TitleContentView : View {
	@Environment(\.font) var font
	@Environment(\.sizeCategory) var sizeCategory
	@Environment(\.colorScheme) var colorScheme
	
	let titleView: AnyView
	let subtitleView: AnyView?
	let popupBar: LNPopupBar
	
	init(titleView: AnyView, subtitleView: AnyView?, popupBar: LNPopupBar) {
		self.titleView = titleView
		self.subtitleView = subtitleView
		self.popupBar = popupBar
	}
	
	var body: some View {
		let titleFont = popupBar.value(forKey: "_titleFont") as! CTFont
		let subtitleFont = popupBar.value(forKey: "_subtitleFont") as! CTFont
		let titleColor = popupBar.value(forKey: "_titleColor") as! UIColor
		let subtitleColor = popupBar.value(forKey: "_subtitleColor") as! UIColor
		
		VStack(spacing: 2) {
			titleView.font(font ?? Font(titleFont)).foregroundColor(Color(titleColor))
			subtitleView.font(font ?? Font(subtitleFont)).foregroundColor(Color(subtitleColor))
		}.lineLimit(1)
	}
}

fileprivate var inheritedNameContainment: String = {
	//InheritedView
	let b64d = "SW5oZXJpdGVkVmlldw==".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return str
}()

internal
extension UIView {
	var _isInheritedView: Bool {
		NSStringFromClass(type(of: self)).contains(inheritedNameContainment)
	}
}

internal
extension View {
	@ViewBuilder func accentTintIfNeeded() -> some View {
		if #available(iOS 26.0, *) {
			self.tint(.accentColor)
		} else {
			self
		}
	}
}
