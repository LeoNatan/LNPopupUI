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
			subtitleView?.font(font ?? Font(subtitleFont)).foregroundColor(Color(subtitleColor))
		}.lineLimit(1)
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

func barItemContainer<Content>(@ViewBuilder _ content: () -> Content) -> AnyView where Content : View {
	let content = {
		Color.clear.toolbar {
			ToolbarItemGroup(placement: .popupBar) {
				content().font(.body)
			}
		}
	}
	
	let view: any View
	if #available(iOS 16.0, *) {
		view = NavigationStack(root: content)
	} else {
		view = NavigationView(content: content).navigationViewStyle(.stack)
	}
	
	return AnyView(view)
}

func barItemContainer<Content>(@ToolbarContentBuilder _ content: () -> Content) -> AnyView where Content : ToolbarContent {
	let content = {
		Color.clear.toolbar {
			content()
		}.font(.body)
	}
	
	let view: any View
	if #available(iOS 16.0, *) {
		view = NavigationStack(root: content)
	} else {
		view = NavigationView(content: content).navigationViewStyle(.stack)
	}
	
	return AnyView(view)
}

func barItemContainer<Content>(_ content: Content) -> AnyView where Content : ToolbarContent {
	let content = {
		Color.clear.toolbar {
			content
		}.font(.body)
	}
	
	let view: any View
	if #available(iOS 16.0, *) {
		view = NavigationStack(root: content)
	} else {
		view = NavigationView(content: content).navigationViewStyle(.stack)
	}
	
	return AnyView(view)
}

internal
func createOrUpdateBarItemAdapter(in popupItem: LNPopupItem, key: String, buttonKeyPath: ReferenceWritableKeyPath<LNPopupItem, [UIBarButtonItem]?>, userNavigationViewWrapper anyView: AnyView?) {
	if let anyView {
		let anyView = AnyView(anyView.accentTintIfNeeded())
		if let adapter = popupItem.value(forKey: key) as? LNPopupBarItemAdapter {
			adapter.rootView = anyView
		} else {
			let adapter = LNPopupBarItemAdapter(rootView: anyView) { [weak popupItem] buttonItems in
				guard let popupItem, popupItem[keyPath: buttonKeyPath] != buttonItems else { return }
				popupItem[keyPath: buttonKeyPath] = buttonItems
			}
			popupItem.setValue(adapter, forKey: key)
		}
	} else {
		popupItem.setValue(nil, forKey: key)
		popupItem[keyPath: buttonKeyPath] = []
	}
}

fileprivate
func titleContentView(fromTitleView titleView: AnyView?, subtitleView: AnyView?, popupBar: LNPopupBar) -> TitleContentView? {
	if let titleView {
		return TitleContentView(titleView: titleView, subtitleView: subtitleView, popupBar: popupBar)
	} else {
		return nil
	}
}

internal
func createOrUpdateTitleAdapter(in popupItem: LNPopupItem, for titleData: LNPopupTitleContentData?, popupBar: LNPopupBar) {
	let view = titleContentView(fromTitleView: titleData?.titleView, subtitleView: titleData?.subtitleView, popupBar: popupBar)
	createOrUpdateTitleAdapter(in: popupItem, for: view)
}

internal
func createOrUpdateTitleAdapter(in popupItem: LNPopupItem, for view: TitleContentView?) {
	if let view {
		if let adapter = popupItem.value(forKey: "swiftuiTitleContentViewController") as? LNPopupBarTitleViewAdapter {
			adapter.rootView = view
		} else {
			let adapter = LNPopupBarTitleViewAdapter(rootView: view)
			popupItem.setValue(adapter, forKey: "swiftuiTitleContentViewController")
		}
	} else {
		popupItem.setValue(nil, forKey: "swiftuiTitleContentViewController")
	}
}

internal
func createOrUpdateImageAdapter(in popupItem: LNPopupItem, for imageData: LNPopupImageData?) {
	if let imageData {
		let contentMode = imageData.contentMode
		var image = imageData.image
		if imageData.resizable {
			image = image.resizable()
		}
		let view = AnyView(image.aspectRatio(imageData.aspectRatio, contentMode: contentMode))
		
		if let adapter = popupItem.value(forKey: "swiftuiImageController") as? LNPopupBarImageAdapter {
			adapter.rootView = view
			adapter.contentMode = contentMode
			adapter.aspectRatio = imageData.aspectRatio
		} else {
			let adapter = LNPopupBarImageAdapter(rootView: view)
			adapter.contentMode = contentMode
			adapter.aspectRatio = imageData.aspectRatio
			popupItem.setValue(adapter, forKey: "swiftuiImageController")
		}
	} else {
		popupItem.setValue(nil, forKey: "swiftuiImageController")
	}
}

@usableFromInline internal
struct EquatableEmptyView: View, Equatable {
	@usableFromInline
	init() {}
	
	@usableFromInline
	var body: some View {
		EmptyView()
	}
}
