//
//  LNPopupProxyViewController.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import UIKit
import LNPopupController
import LNSwiftUIUtils

internal class LNPopupImplicitAnimationController {
	fileprivate var willNotificationName: NSNotification.Name = {
		//UIWindowWillRotateNotification
		let b64d = "VUlXaW5kb3dXaWxsUm90YXRlTm90aWZpY2F0aW9u".data(using: .utf8)!
		let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
		return NSNotification.Name(rawValue: str)
	}()
	
	fileprivate var didNotificationName: NSNotification.Name = {
		//UIWindowDidRotateNotification
		let b64d = "VUlXaW5kb3dEaWRSb3RhdGVOb3RpZmljYXRpb24=".data(using: .utf8)!
		let str = String(data: Data(base64Encoded: b64d)!, encoding: .utf8)!
		return NSNotification.Name(rawValue: str)
	}()
	
	private weak var window: UIWindow?
	private var count = 0
	
	init(withWindow window: UIWindow) {
		self.window = window
	}
	
	func push() {
		if count == 0, let window {
			NotificationCenter.default.post(name: willNotificationName, object: window, userInfo: ["LNPopupIgnore": true])
		}
		
		count += 1
	}
	
	func pop() {
		count -= 1
		
		if count == 0, let window {
			NotificationCenter.default.post(name: didNotificationName, object: window, userInfo: ["LNPopupIgnore": true])
		}
	}
}

internal class LNPopupBarImageAdapter: UIHostingController<AnyView> {
	@objc(_ln_popupUIRequiresZeroInsets) let popupUIRequiresZeroInsets = true
	
	var contentMode: ContentMode = .fit {
		didSet {
			if #available(iOS 16.0, *) {
				sizingOptions = contentMode == .fit ? [.preferredContentSize] : []
			}
		}
	}
	
	var aspectRatio: CGFloat? = nil
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
	}
	
	override var preferredContentSize: CGSize {
		get {
			guard contentMode != .fill else {
				return CGSize(width: 1, height: 1)
			}
			
			if let aspectRatio {
				return CGSize(width: aspectRatio, height: 1)
			}
			
			return super.preferredContentSize
		}
		set {
			super.preferredContentSize = newValue
		}
	}
}

internal class LNPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, LNPopupPresentationDelegate, UIContextMenuInteractionDelegate where Content: View, PopupContent: View {
	var currentPopupState: LNPopupState<PopupContent>! = nil
	var popupViewController: UIViewController?
	
	var popupContextMenuViewController: UIHostingController<AnyView>?
	var popupContextMenuInteraction: UIContextMenuInteraction?
	
	weak var interactionContainerView: UIView?
	
	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
	}
	
	var readyForHandling = false {
		didSet {
			guard readyForHandling != oldValue else {
				return
			}
			
			guard let waitingStateHandle else {
				return
			}
			
			waitingStateHandle(false)
			self.waitingStateHandle = nil
		}
	}
	var waitingStateHandle: ((Bool) -> Void)?
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		readyForHandling = true
	}
	
	static fileprivate func cast<T: View>(_ value: Any?, to type: T) -> LNPopupContentHostingController<T>? {
		return value as? LNPopupContentHostingController<T>
	}
	
	fileprivate var target: UIViewController {
		let appropriateChild = children.first(where: { $0.view.frame == self.view.bounds })
		
		//Support NavigationSplitView
		if appropriateChild == nil && self.splitViewController != nil && self.navigationController != nil {
			return self.navigationController!
		}
		return appropriateChild ?? self
	}
	
	func viewHandler(_ state: LNPopupState<PopupContent>) -> (() -> Void) {
		let view = self.currentPopupState.content!()
		
		return {
			if let popupViewController = LNPopupProxyViewController.cast(self.popupViewController, to: view.self) {
				popupViewController.popupContentRootView = view
			} else {
				self.popupViewController = LNPopupContentHostingController(content: self.currentPopupState.content!)
			}
		}
	}
	
	func viewControllerHandler(_ state: LNPopupState<PopupContent>) -> (() -> Void) {
		let viewController = state.contentController!
		
		return {
			self.popupViewController = viewController
		}
	}
	
	lazy var implicitAnimationController: LNPopupImplicitAnimationController = {
		return LNPopupImplicitAnimationController(withWindow: view.window!)
	}()
	
	weak var lastKnownTarget: UIViewController?
	var currentSmallPopupState: LNPopupSmallState = (false, nil)
	func handlePopupState(_ state: LNPopupState<PopupContent>, animated: Bool = true) {
		currentPopupState = state
			
		let popupContentHandler = state.content != nil ? viewHandler(state) : viewControllerHandler(state)

		let handler : (Bool) -> Void = { animated in
			let target = self.target
			
			UIView.performWithoutAnimation {
				let appearance = target.popupBar.standardAppearance.copy()
				
				target.popupBar.setValue(true, forKey: "_applySwiftUILayoutFixes")
				target.popupPresentationDelegate = self
				
				let inheritsEnvironmentFont = self.currentPopupState.inheritsEnvironmentFont?.consume(self)
				if(inheritsEnvironmentFont == nil || inheritsEnvironmentFont! == true) {
					target.popupBar.setValue(self.currentPopupState.inheritedFont, forKey: "swiftuiInheritedFont")
				}
				
				if let closeButtonStyle = self.currentPopupState.closeButtonStyle?.consume(self) {
					target.popupContentView.popupCloseButtonStyle = closeButtonStyle
				}
				if let interactionStyle = self.currentPopupState.interactionStyle?.consume(self) {
					target.popupInteractionStyle = interactionStyle
				}
				if let barProgressViewStyle = self.currentPopupState.barProgressViewStyle?.consume(self) {
					target.popupBar.progressViewStyle = barProgressViewStyle
				}
				if let barMarqueeScrollEnabled = self.currentPopupState.barMarqueeScrollEnabled?.consume(self) {
					appearance.marqueeScrollEnabled = barMarqueeScrollEnabled
				}
				if let hapticFeedbackEnabled = self.currentPopupState.hapticFeedbackEnabled?.consume(self) {
					target.allowPopupHapticFeedbackGeneration = hapticFeedbackEnabled
				}
				if let limitFloatingContentWidth = self.currentPopupState.limitFloatingContentWidth?.consume(self) {
					target.popupBar.limitFloatingContentWidth = limitFloatingContentWidth
				}
				if let marqueeRate = self.currentPopupState.marqueeRate?.consume(self) {
					appearance.marqueeScrollRate = marqueeRate
				}
				if let marqueeDelay = self.currentPopupState.marqueeDelay?.consume(self) {
					appearance.marqueeScrollDelay = marqueeDelay
				}
				if let coordinateMarqueeAnimations = self.currentPopupState.coordinateMarqueeAnimations?.consume(self) {
					appearance.coordinateMarqueeScroll = coordinateMarqueeAnimations
				}
				if #available(iOS 15.0, *), let popupBarTitleTextAttributes = self.currentPopupState.barTitleTextAttributes?.consume(self) as? AttributeContainer {
					appearance.titleTextAttributes = popupBarTitleTextAttributes.swiftUIToUIKit
				}
				if #available(iOS 15.0, *), let popupBarSubtitleTextAttributes = self.currentPopupState.barSubtitleTextAttributes?.consume(self) as? AttributeContainer {
					appearance.subtitleTextAttributes = popupBarSubtitleTextAttributes.swiftUIToUIKit
				}
				if let shouldExtendPopupBarUnderSafeArea = self.currentPopupState.shouldExtendPopupBarUnderSafeArea?.consume(self) {
					target.shouldExtendPopupBarUnderSafeArea = shouldExtendPopupBarUnderSafeArea
				}
				if let inheritsAppearanceFromDockingView = self.currentPopupState.inheritsAppearanceFromDockingView?.consume(self) {
					target.popupBar.inheritsAppearanceFromDockingView = inheritsAppearanceFromDockingView
				}
				if let customBarView = self.currentPopupState.customBarView?.consume(self) {
					let rv: LNPopupCustomBarHostingController<AnyView>
					if let customController = target.popupBar.customBarViewController as? LNPopupCustomBarHostingController<AnyView> {
						rv = customController
						rv.content = customBarView.popupBarCustomBarView
					} else {
						rv = LNPopupCustomBarHostingController(content: { customBarView.popupBarCustomBarView })
						target.popupBar.customBarViewController = rv
					}
					rv._wantsDefaultTapGestureRecognizer = customBarView.wantsDefaultTapGesture
					rv._wantsDefaultPanGestureRecognizer = customBarView.wantsDefaultPanGesture
					rv._wantsDefaultHighlightGestureRecognizer = customBarView.wantsDefaultHighlightGesture
				} else {
					target.popupBar.customBarViewController = nil
					if let barStyle = self.currentPopupState.barStyle?.consume(self) {
						target.popupBar.barStyle = barStyle
					}
					
					if let barBackgroundEffect = self.currentPopupState.barBackgroundEffect?.consume(self) {
						appearance.backgroundEffect = barBackgroundEffect
					}
					
					if let barFloatingBackgroundEffect = self.currentPopupState.barFloatingBackgroundEffect?.consume(self) {
						appearance.floatingBackgroundEffect = barFloatingBackgroundEffect
					}
					
					if let barFloatingBackgroundShadow = self.currentPopupState.barFloatingBackgroundShadow?.consume(self) {
						appearance.floatingBarBackgroundShadow = barFloatingBackgroundShadow
					}
					
					if let barImageShadow = self.currentPopupState.barImageShadow?.consume(self) {
						appearance.imageShadow = barImageShadow
					}
					
					target.popupBar.standardAppearance = appearance
				}
				
				if let contextMenu = self.currentPopupState.contextMenu?.consume(self) {
					let contextHost = AnyView(Color.green.frame(width: 2, height: 2).contextMenu {
						contextMenu
					})
					
					if self.popupContextMenuViewController == nil {
						self.popupContextMenuViewController = UIHostingController(rootView: contextHost)
						self.popupContextMenuViewController!.view!.translatesAutoresizingMaskIntoConstraints = true
						self.popupContextMenuViewController!.view!.frame = CGRect(x: -2, y: -2, width: 2, height: 2)
						target.popupBar.addSubview(self.popupContextMenuViewController!.view!)
					} else {
						self.popupContextMenuViewController!.rootView = contextHost
					}
					
					if self.popupContextMenuInteraction == nil {
						self.popupContextMenuInteraction = UIContextMenuInteraction(delegate: self)
						target.popupBar.addInteraction(self.popupContextMenuInteraction!)
					}
				} else {
					self.popupContextMenuViewController?.view?.removeFromSuperview()
					self.popupContextMenuViewController = nil
					if let popupContextMenuInteraction = self.popupContextMenuInteraction {
						target.popupBar.removeInteraction(popupContextMenuInteraction)
					}
					self.popupContextMenuInteraction = nil
				}
				
				self.currentPopupState.barCustomizer?.consume(self)?(target.popupBar)
				self.currentPopupState.contentViewCustomizer?.consume(self)?(target.popupContentView)
				
				target.popupBar.layoutIfNeeded()
			}
			
			self.implicitAnimationController.push()
			let endImplicitAnims = { [weak self] in
				self?.implicitAnimationController.pop()
			}
			
			let newSmallState = self.currentPopupState.smallState
			
			if newSmallState.isBarPresented {
				popupContentHandler()
			}
			
			guard self.lastKnownTarget != target || self.currentSmallPopupState != newSmallState else {
				endImplicitAnims()
				return
			}
			
			let animated = animated && self.lastKnownTarget == target
			
			self.currentSmallPopupState = newSmallState
			self.lastKnownTarget = target
			
			if newSmallState.isBarPresented == true {
				let targetPresentationState: UIViewController.PopupPresentationState = UIViewController.PopupPresentationState(rawValue: target.value(forKeyPath: "ln_popupController.popupControllerTargetState") as! Int)!
				
				if targetPresentationState.rawValue >= UIViewController.PopupPresentationState.barPresented.rawValue {
					if let isPopupOpen = newSmallState.isPopupOpen {
						if isPopupOpen {
							target.openPopup(animated: animated) {
								endImplicitAnims()
							}
						} else {
							target.closePopup(animated: animated) {
								endImplicitAnims()
							}
						}
					} else {
						endImplicitAnims()
					}
				} else {
					target.presentPopupBar(with: self.popupViewController!, openPopup: self.currentPopupState.isPopupOpen?.wrappedValue ?? false, animated: animated) {
						endImplicitAnims()
					}
				}
			} else {
				target.dismissPopupBar(animated: true) {
					endImplicitAnims()
				}
			}
		}
		
		if readyForHandling {
			handler(animated)
		} else {
			waitingStateHandle = handler
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: nil) { _ in
			if self.lastKnownTarget != self.target {
				self.handlePopupState(self.currentPopupState, animated: false)
			}
		}
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
	
	func popupPresentationControllerWillPresentPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentSmallPopupState = (true, currentSmallPopupState.isPopupOpen)
		DispatchQueue.main.async {
			self.currentPopupState?.isBarPresented.wrappedValue = true
		}
	}
	
	func popupPresentationControllerWillDismissPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentSmallPopupState = (false, currentSmallPopupState.isPopupOpen)
		DispatchQueue.main.async {
			self.currentPopupState?.isBarPresented.wrappedValue = false
		}
		
		popupViewController = nil
		popupContextMenuViewController = nil
		popupContextMenuInteraction = nil
		interactionContainerView = nil
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, willOpenPopupWithContentController popupContentController: UIViewController, animated: Bool) {
		if currentPopupState.isPopupOpen != nil {
			currentSmallPopupState = (currentSmallPopupState.isBarPresented, true)
		}
		DispatchQueue.main.async {
			self.currentPopupState?.isPopupOpen?.wrappedValue = true
		}
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, didOpenPopupWithContentController popupContentController: UIViewController, animated: Bool) {
		currentPopupState?.onOpen?()
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, willClosePopupWithContentController popupContentController: UIViewController, animated: Bool) {
		if currentPopupState.isPopupOpen != nil {
			currentSmallPopupState = (currentSmallPopupState.isBarPresented, false)
		}
		DispatchQueue.main.async {
			self.currentPopupState?.isPopupOpen?.wrappedValue = false
		}
	}
	
	func popupPresentationController(_ popupPresentationController: UIViewController, didClosePopupWithContentController popupContentController: UIViewController, animated: Bool) {
		currentPopupState?.onClose?()
	}
}
