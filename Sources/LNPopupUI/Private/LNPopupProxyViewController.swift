//
//  LNPopupUIContentController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import UIKit
import LNPopupController

internal class LNPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, LNPopupPresentationDelegate, UIContextMenuInteractionDelegate where Content: View, PopupContent: View {
	var currentPopupState: LNPopupState<PopupContent>! = nil
	var popupViewController: UIViewController?
	
	var popupContextMenuViewController: UIHostingController<AnyView>?
	var popupContextMenuInteraction: UIContextMenuInteraction?
	
	var leadingBarItemsController: UIHostingController<AnyView>? = nil
	var trailingBarItemsController: UIHostingController<AnyView>? = nil
	var leadingBarButtonItem: UIBarButtonItem? = nil
	var trailingBarButtonItem: UIBarButtonItem? = nil
	
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
		return children.first ?? self
	}
	
	fileprivate func createOrUpdateHostingControllerForAnyView(_ vc: inout UIHostingController<AnyView>?, view: AnyView, barButtonItem: inout UIBarButtonItem?, targetBarButtons: ([UIBarButtonItem]) -> Void, leadSpacing: Bool, trailingSpacing: Bool) {
		
		let anyView = AnyView(erasing: view.font(.system(size: 20)))
		
		UIView.performWithoutAnimation {
			if let vc = vc {
				vc.rootView = anyView
				vc.view.removeConstraints(vc.view.constraints)
				vc.view.setNeedsLayout()
				let size = vc.sizeThatFits(in: CGSize(width: .max, height: .max))
				NSLayoutConstraint.activate([
					vc.view.widthAnchor.constraint(equalToConstant: size.width),
					vc.view.heightAnchor.constraint(equalToConstant: min(size.height, 44)),
				])

				barButtonItem!.customView = vc.view
			} else {
				vc = UIHostingController<AnyView>(rootView: anyView)
				vc!.view.backgroundColor = .clear
				vc!.view.translatesAutoresizingMaskIntoConstraints = false
				let size = vc!.sizeThatFits(in: CGSize(width: .max, height: .max))
				NSLayoutConstraint.activate([
					vc!.view.widthAnchor.constraint(equalToConstant: size.width),
					vc!.view.heightAnchor.constraint(equalToConstant: min(size.height, 44)),
				])
				
				barButtonItem = UIBarButtonItem(customView: vc!.view)
				
				targetBarButtons([barButtonItem!])
			}
		}
	}
	
	func anyView(fromView view: AnyView, isTitle: Bool) -> AnyView {
		let font = self.target.popupBar.value(forKey: isTitle ? "_titleFont" : "_subtitleFont") as! CTFont
		let color = self.target.popupBar.value(forKey: isTitle ? "_titleColor" : "_subtitleColor") as! UIColor
		return AnyView(erasing: view.lineLimit(1).font(Font(font)).foregroundColor(Color(color)))
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
					
					if let titleView = titleData?.titleView {
						let anyView = self.anyView(fromView: titleView, isTitle: true)
						if let titleController = self.popupViewController?.popupItem.value(forKey: "swiftuiTitleController") as? UIHostingController<AnyView> {
							titleController.rootView = anyView
						} else {
							self.popupViewController?.popupItem.setValue(UIHostingController(rootView: anyView), forKey: "swiftuiTitleController")
						}
					} else {
						self.popupViewController?.popupItem.setValue(nil, forKey: "swiftuiTitleController")
					}
					
					if let subtitleView = titleData?.subtitleView {
						let anyView = self.anyView(fromView: subtitleView, isTitle: false)
						if let subtitleController = self.popupViewController?.popupItem.value(forKey: "swiftuiSubtitleController") as? UIHostingController<AnyView> {
							subtitleController.rootView = anyView
						} else {
							self.popupViewController?.popupItem.setValue(UIHostingController(rootView: anyView), forKey: "swiftuiSubtitleController")
						}
					} else {
						self.popupViewController?.popupItem.setValue(nil, forKey: "swiftuiSubtitleController")
					}
				}
				.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] image in
					let anyView = AnyView(erasing: image?.edgesIgnoringSafeArea(.all))
					if let imageController = self?.popupViewController?.popupItem.value(forKey: "swiftuiImageController") as? UIHostingController<AnyView> {
						imageController.rootView = anyView
					} else {
						self?.popupViewController?.popupItem.setValue(UIHostingController(rootView: anyView), forKey: "swiftuiImageController")
					}
				}
				.onPreferenceChange(LNPopupProgressPreferenceKey.self) { [weak self] progress in
					self?.popupViewController?.popupItem.progress = progress ?? 0.0
				}
				.onPreferenceChange(LNPopupLeadingBarItemsPreferenceKey.self) { [weak self] view in
					if let self = self, let anyView = view?.anyView, let popupItem = self.popupViewController?.popupItem {
						self.createOrUpdateHostingControllerForAnyView(&self.leadingBarItemsController, view: anyView, barButtonItem: &self.leadingBarButtonItem, targetBarButtons: { popupItem.leadingBarButtonItems = $0 }, leadSpacing: false, trailingSpacing: false)
					}
				}
				.onPreferenceChange(LNPopupTrailingBarItemsPreferenceKey.self) { [weak self] view in
					if let self = self, let anyView = view?.anyView, let popupItem = self.popupViewController?.popupItem {
						self.createOrUpdateHostingControllerForAnyView(&self.trailingBarItemsController, view: anyView, barButtonItem: &self.trailingBarButtonItem, targetBarButtons: { popupItem.trailingBarButtonItems = $0 }, leadSpacing: false, trailingSpacing: false)
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
			if state.content != nil {
				self.target.popupBar.setValue(true, forKey: "_applySwiftUILayoutFixes")
			}
			
			self.target.popupPresentationDelegate = self
			
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
			if let marqueeRate = self.currentPopupState.marqueeRate?.consume(self) {
				self.target.popupBar.standardAppearance.marqueeScrollRate = marqueeRate
			}
			if let marqueeDelay = self.currentPopupState.marqueeDelay?.consume(self) {
				self.target.popupBar.standardAppearance.marqueeScrollDelay = marqueeDelay
			}
			if let coordinateMarqueeAnimations = self.currentPopupState.coordinateMarqueeAnimations?.consume(self) {
				self.target.popupBar.standardAppearance.coordinateMarqueeScroll = coordinateMarqueeAnimations
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
			
			if self.currentPopupState.isBarPresented == true {
				popupContentHandler()
				
				if self.target.popupPresentationState.rawValue >= LNPopupPresentationState.barPresented.rawValue {
					if let isPopupOpen = self.currentPopupState.isPopupOpen {
						if isPopupOpen.wrappedValue == true {
							self.target.openPopup(animated: true, completion: nil)
						} else {
							self.target.closePopup(animated: true, completion: nil)
						}
					}
				} else {
					self.target.presentPopupBar(withContentViewController: self.popupViewController!, openPopup: self.currentPopupState.isPopupOpen?.wrappedValue ?? false, animated: animated, completion: nil)
				}
			} else {
				self.target.dismissPopupBar(animated: true, completion: nil)
			}
		}
		
		if readyForHandling {
			handler(true)
		} else {
			waitingStateHandle = handler
		}
	}
	
	override func addChild(_ childController: UIViewController) {
//		print("Child: \(target!)")
		super.addChild(childController)
		
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
