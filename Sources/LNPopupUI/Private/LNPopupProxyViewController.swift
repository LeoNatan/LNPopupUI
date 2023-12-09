//
//  LNPopupUIContentController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import UIKit
import LNPopupController
import LNSwiftUIUtils

var willNotificationName: NSNotification.Name = {
	//UIWindowWillRotateNotification
	let b64d = "VUlXaW5kb3dXaWxsUm90YXRlTm90aWZpY2F0aW9u".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return NSNotification.Name(rawValue: str)
}()

var didNotificationDid: NSNotification.Name = {
	//UIWindowDidRotateNotification
	let b64d = "VUlXaW5kb3dEaWRSb3RhdGVOb3RpZmljYXRpb24=".data(using: .utf8)!
	let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
	return NSNotification.Name(rawValue: str)
}()

internal class LNPopupBarImageAdapter: UIHostingController<Image?> {
	@objc(_ln_popupUIRequiresZeroInsets) let popupUIRequiresZeroInsets = true
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		
		print(view.safeAreaInsets)
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
		
		let nav = self.children.first as! UINavigationController
		self.updater(nav.toolbar.items)
	}
}

fileprivate struct TitleContentView : View {
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
			titleView.font(Font(titleFont)).foregroundColor(Color(titleColor))
			subtitleView.font(Font(subtitleFont)).foregroundColor(Color(subtitleColor))
		}.lineLimit(1)
	}
}

internal class LNPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, LNPopupPresentationDelegate, UIContextMenuInteractionDelegate where Content: View, PopupContent: View {
	var currentPopupState: LNPopupState<PopupContent>! = nil
	var popupViewController: UIViewController?
	
	var popupContextMenuViewController: UIHostingController<AnyView>?
	var popupContextMenuInteraction: UIContextMenuInteraction?
	
	var leadingBarItemsController: LNPopupBarItemAdapter? = nil
	var trailingBarItemsController: LNPopupBarItemAdapter? = nil
	
	weak var interactionContainerView: UIView?
	
	var readyForHandling = false {
		didSet {
			if let waitingStateHandle = waitingStateHandle {
				self.waitingStateHandle = nil
				waitingStateHandle(false)
			}
		}
	}
	var waitingStateHandle: ((Bool) -> Void)?
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		readyForHandling = true
	}
	
	fileprivate func cast<T>(value: Any?, to type: T) -> LNPopupUIContentController<T>? where T: View {
		return value as? LNPopupUIContentController<T>
	}
	
	fileprivate var target: UIViewController {
		//Support NavigationSplitView
		if children.first == nil && self.splitViewController != nil && self.navigationController != nil {
			return self.navigationController!
		}
		return children.first ?? self
	}
	
	@available(iOS 14.0, *)
	fileprivate func createOrUpdateBarItemAdapter(_ vc: inout LNPopupBarItemAdapter?, userNavigationViewWrapper anyView: AnyView, barButtonUpdater: @escaping ([UIBarButtonItem]?) -> Void) {
		UIView.performWithoutAnimation {
			if let vc = vc {
				vc.rootView = anyView
			} else {
				vc = LNPopupBarItemAdapter(rootView: anyView, updater: barButtonUpdater)
			}
		}
	}
	
	@ViewBuilder func titleContentView(fromTitleView titleView: AnyView, subtitleView: AnyView?) -> some View {
		TitleContentView(titleView: titleView, subtitleView: subtitleView, popupBar: target.popupBar)
	}
	
	func viewHandler(_ state: LNPopupState<PopupContent>) -> (() -> Void) {
		let view = {
			return self.currentPopupState.content!()
				.onPreferenceChange(LNPopupTitlePreferenceKey.self) { [weak self] titleData in
					self?.popupViewController?.popupItem.title = titleData?.title
					self?.popupViewController?.popupItem.subtitle = titleData?.subtitle
				}
				.onPreferenceChange(LNPopupTextTitlePreferenceKey.self) { [weak self] titleData in
					guard let self = self else {
						return
					}
					
					if let titleData = titleData {
						if #available(iOS 16.0, *) {
							let config = UIHostingConfiguration {
								self.titleContentView(fromTitleView: titleData.titleView, subtitleView: titleData.subtitleView)
							}
							self.popupViewController?.popupItem.setValue(config.makeContentView(), forKey: "swiftuiTitleContentView")
						} else {
							let anyView = AnyView(titleContentView(fromTitleView: titleData.titleView, subtitleView: titleData.subtitleView))
							self.popupViewController?.popupItem.setValue(UIHostingController(rootView: anyView).view, forKey: "swiftuiTitleContentView")
						}
					} else {
						self.popupViewController?.popupItem.setValue(nil, forKey: "swiftuiTitleContentView")
					}
				}
				.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] image in
					if let imageController = self?.popupViewController?.popupItem.value(forKey: "swiftuiImageController") as? LNPopupBarImageAdapter {
						imageController.rootView = image
					} else {
						self?.popupViewController?.popupItem.setValue(LNPopupBarImageAdapter(rootView: image), forKey: "swiftuiImageController")
					}
				}
				.onPreferenceChange(LNPopupProgressPreferenceKey.self) { [weak self] progress in
					self?.popupViewController?.popupItem.progress = progress ?? 0.0
				}
				.onPreferenceChange(LNPopupLeadingBarItemsPreferenceKey.self) { [weak self] view in
					if let self = self, let anyView = view?.anyView, let popupItem = self.popupViewController?.popupItem {
						self.createOrUpdateBarItemAdapter(&self.leadingBarItemsController, userNavigationViewWrapper: anyView, barButtonUpdater: { popupItem.leadingBarButtonItems = $0 })
						popupItem.setValue(self.leadingBarItemsController!, forKey: "swiftuiHiddenLeadingController")
					}
				}
				.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] view in
					if let self = self, let anyView = view?.anyView, let popupItem = self.popupViewController?.popupItem {
						self.createOrUpdateBarItemAdapter(&self.trailingBarItemsController, userNavigationViewWrapper: anyView, barButtonUpdater: { popupItem.trailingBarButtonItems = $0 })
						popupItem.setValue(self.trailingBarItemsController!, forKey: "swiftuiHiddenTrailingController")
					}
				}
		}()
		
		return {
			if let popupViewController = self.cast(value: self.popupViewController, to: view.self) {
				popupViewController.rootView = view
			} else {
				self.popupViewController = LNPopupUIContentController(rootView: view)
			}
		}
	}
	
	func viewControllerHandler(_ state: LNPopupState<PopupContent>) -> (() -> Void) {
		let viewController = state.contentController!
		
		return {
			self.popupViewController = viewController
		}
	}
	
	func handlePopupState(_ state: LNPopupState<PopupContent>) {
		currentPopupState = state
		
		let popupContentHandler = state.content != nil ? viewHandler(state) : viewControllerHandler(state)

		let handler : (Bool) -> Void = { animated in
			self.target.popupBar.setValue(true, forKey: "_applySwiftUILayoutFixes")
			self.target.popupPresentationDelegate = self
			
			let inheritsEnvironmentFont = self.currentPopupState.inheritsEnvironmentFont?.consume(self)
			if(inheritsEnvironmentFont == nil || inheritsEnvironmentFont! == true) {
				self.target.popupBar.setValue(self.currentPopupState.inheritedFont, forKey: "swiftuiInheritedFont")
			}
			
			if let closeButtonStyle = self.currentPopupState.closeButtonStyle?.consume(self) {
				self.target.popupContentView.popupCloseButtonStyle = closeButtonStyle
			}
			if let interactionStyle = self.currentPopupState.interactionStyle?.consume(self) {
				self.target.popupInteractionStyle = interactionStyle
			}
			if let barProgressViewStyle = self.currentPopupState.barProgressViewStyle?.consume(self) {
				self.target.popupBar.progressViewStyle = barProgressViewStyle
			}
			if let barMarqueeScrollEnabled = self.currentPopupState.barMarqueeScrollEnabled?.consume(self) {
				self.target.popupBar.standardAppearance.marqueeScrollEnabled = barMarqueeScrollEnabled
			}
			if let hapticFeedbackEnabled = self.currentPopupState.hapticFeedbackEnabled?.consume(self) {
				self.target.allowPopupHapticFeedbackGeneration = hapticFeedbackEnabled
			}
			if let marqueeRate = self.currentPopupState.marqueeRate?.consume(self) {
				self.target.popupBar.standardAppearance.marqueeScrollRate = marqueeRate
			}
			if let marqueeDelay = self.currentPopupState.marqueeDelay?.consume(self) {
				self.target.popupBar.standardAppearance.marqueeScrollDelay = marqueeDelay
			}
			if let coordinateMarqueeAnimations = self.currentPopupState.coordinateMarqueeAnimations?.consume(self) {
				self.target.popupBar.standardAppearance.coordinateMarqueeScroll = coordinateMarqueeAnimations
			}
			if #available(iOS 15.0, *), let popupBarTitleTextAttributes = self.currentPopupState.barTitleTextAttributes?.consume(self) as? AttributeContainer {
				self.target.popupBar.standardAppearance.titleTextAttributes = popupBarTitleTextAttributes.swiftUIToUIKit
			}
			if #available(iOS 15.0, *), let popupBarSubtitleTextAttributes = self.currentPopupState.barSubtitleTextAttributes?.consume(self) as? AttributeContainer {
				self.target.popupBar.standardAppearance.subtitleTextAttributes = popupBarSubtitleTextAttributes.swiftUIToUIKit
			}
			if let shouldExtendPopupBarUnderSafeArea = self.currentPopupState.shouldExtendPopupBarUnderSafeArea?.consume(self) {
				self.target.shouldExtendPopupBarUnderSafeArea = shouldExtendPopupBarUnderSafeArea
			}
			if let inheritsAppearanceFromDockingView = self.currentPopupState.inheritsAppearanceFromDockingView?.consume(self) {
				self.target.popupBar.inheritsAppearanceFromDockingView = inheritsAppearanceFromDockingView
			}
			if let customBarView = self.currentPopupState.customBarView?.consume(self) {
				let rv: LNPopupUICustomPopupBarController
				if let customController = self.target.popupBar.customBarViewController as? LNPopupUICustomPopupBarController {
					rv = customController
					rv.setAnyView(customBarView.popupBarCustomBarView)
				} else {
					rv = LNPopupUICustomPopupBarController(anyView: customBarView.popupBarCustomBarView)
					self.target.popupBar.customBarViewController = rv
				}
				rv._wantsDefaultTapGestureRecognizer = customBarView.wantsDefaultTapGesture
				rv._wantsDefaultPanGestureRecognizer = customBarView.wantsDefaultPanGesture
				rv._wantsDefaultHighlightGestureRecognizer = customBarView.wantsDefaultHighlightGesture
			} else {
				self.target.popupBar.customBarViewController = nil
				if let barStyle = self.currentPopupState.barStyle?.consume(self) {
					self.target.popupBar.barStyle = barStyle
				}
				
				if let barBackgroundEffect = self.currentPopupState.barBackgroundEffect?.consume(self) {
					self.target.popupBar.standardAppearance.backgroundEffect = barBackgroundEffect
				}
				
				if let barFloatingBackgroundEffect = self.currentPopupState.barFloatingBackgroundEffect?.consume(self) {
					self.target.popupBar.standardAppearance.floatingBackgroundEffect = barFloatingBackgroundEffect
				}
				
				if let barFloatingBackgroundShadow = self.currentPopupState.barFloatingBackgroundShadow?.consume(self) {
					self.target.popupBar.standardAppearance.floatingBarBackgroundShadow = barFloatingBackgroundShadow
				}
				
				if let barImageShadow = self.currentPopupState.barImageShadow?.consume(self) {
					self.target.popupBar.standardAppearance.imageShadow = barImageShadow
				}
			}
			
			if let contextMenu = self.currentPopupState.contextMenu?.consume(self) {
				let contextHost = AnyView(Color.green.frame(width: 2, height: 2).contextMenu {
					contextMenu
				})
				
				if self.popupContextMenuViewController == nil {
					self.popupContextMenuViewController = UIHostingController(rootView: contextHost)
					self.popupContextMenuViewController!.view!.translatesAutoresizingMaskIntoConstraints = true
					self.popupContextMenuViewController!.view!.frame = CGRect(x: -2, y: -2, width: 2, height: 2)
					self.target.popupBar.addSubview(self.popupContextMenuViewController!.view!)
				} else {
					self.popupContextMenuViewController!.rootView = contextHost
				}
				
				if self.popupContextMenuInteraction == nil {
					self.popupContextMenuInteraction = UIContextMenuInteraction(delegate: self)
					self.target.popupBar.addInteraction(self.popupContextMenuInteraction!)
				}
			} else {
				self.popupContextMenuViewController?.view?.removeFromSuperview()
				self.popupContextMenuViewController = nil
				if let popupContextMenuInteraction = self.popupContextMenuInteraction {
					self.target.popupBar.removeInteraction(popupContextMenuInteraction)
				}
				self.popupContextMenuInteraction = nil
			}
			
			self.currentPopupState.barCustomizer?.consume(self)?(self.target.popupBar)
			self.currentPopupState.contentViewCustomizer?.consume(self)?(self.target.popupContentView)
			
			NotificationCenter.default.post(name: willNotificationName, object: self.view.window, userInfo: ["LNPopupIgnore": true])
			let endImplicitAnims = {
				NotificationCenter.default.post(name: didNotificationDid, object: self.view.window, userInfo: ["LNPopupIgnore": true])
			}
			
			if self.currentPopupState.isBarPresented == true {
				popupContentHandler()
				
				if self.target.popupPresentationState.rawValue >= UIViewController.PopupPresentationState.barPresented.rawValue {
					if let isPopupOpen = self.currentPopupState.isPopupOpen {
						if isPopupOpen.wrappedValue == true {
							self.target.openPopup(animated: true) {
								endImplicitAnims()
							}
						} else {
							self.target.closePopup(animated: true) {
								endImplicitAnims()
							}
						}
					}
				} else {
					self.target.presentPopupBar(withContentViewController: self.popupViewController!, openPopup: self.currentPopupState.isPopupOpen?.wrappedValue ?? false, animated: animated) {
						endImplicitAnims()
					}
				}
			} else {
				self.target.dismissPopupBar(animated: true) {
					endImplicitAnims()
				}
			}
		}
		
		if readyForHandling {
			handler(true)
		} else {
			waitingStateHandle = handler
		}
	}
	
	override func addChild(_ childController: UIViewController) {
		super.addChild(childController)
		
//		print("Child: \(target)")
		
		readyForHandling = true
	}
	
	//MARK: UIContextMenuInteractionDelegate
	
	fileprivate var actualInteraction: UIContextMenuInteraction? {
		return self.popupContextMenuViewController?.view?.interactions.first(where: { $0 is UIContextMenuInteraction }) as? UIContextMenuInteraction
	}
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return actualInteraction?.delegate?.contextMenuInteraction(interaction, configurationForMenuAtLocation: CGPoint(x: 1.0, y: 1.0))
	}
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		actualInteraction?.delegate?.contextMenuInteraction?(interaction, willPerformPreviewActionForMenuWith: configuration, animator: animator)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		actualInteraction?.delegate?.contextMenuInteraction?(interaction, willEndFor: configuration, animator: animator)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		actualInteraction?.delegate?.contextMenuInteraction?(interaction, willDisplayMenuFor: configuration, animator: animator)
	}
	
	//MARK: LNPopupPresentationDelegate
	
	func popupPresentationControllerDidPresentPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isBarPresented = true
	}
	
	func popupPresentationControllerDidDismissPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isBarPresented = false
		popupViewController = nil
		popupContextMenuViewController = nil
		popupContextMenuInteraction = nil
		leadingBarItemsController = nil
		trailingBarItemsController = nil
		interactionContainerView = nil
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, didOpenPopupWithContentController popupContentController: UIViewController, animated: Bool) {
		currentPopupState?.isPopupOpen?.wrappedValue = true
		
		currentPopupState?.onOpen?()
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, didClosePopupWithContentController popupContentController: UIViewController, animated: Bool) {
		currentPopupState?.isPopupOpen?.wrappedValue = false
		
		currentPopupState?.onClose?()
	}
}
