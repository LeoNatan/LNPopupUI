//
//  LNPopupUIContentController.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import UIKit
import LNPopupController

internal class LNPopupProxyViewController<Content, PopupContent> : UIHostingController<Content>, LNPopupPresentationDelegate where Content: View, PopupContent: View {
	var currentPopupState: LNPopupState<PopupContent>? = nil
	var popupViewController: UIViewController?
	
	var leadingBarItemsController: UIHostingController<AnyView>? = nil
	var trailingBarItemsController: UIHostingController<AnyView>? = nil
	var leadingBarButtonItem: UIBarButtonItem? = nil
	var trailingBarButtonItem: UIBarButtonItem? = nil
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	fileprivate func cast<T>(value: Any, to type: T) -> LNPopupUIContentController<T> where T: View {
		return value as! LNPopupUIContentController<T>
	}
	
	fileprivate var target: UIViewController {
		return children.first ?? self
	}
	
	fileprivate func createOrUpdateHostingControllerForAnyView(_ vc: inout UIHostingController<AnyView>?, view: AnyView, barButtonItem: inout UIBarButtonItem?, targetBarButtons: ([UIBarButtonItem]) -> Void, leadSpacing: Bool, trailingSpacing: Bool) {
		if let vc = vc {
			vc.rootView = view
			vc.view.removeConstraints(vc.view.constraints)
			vc.view.setNeedsLayout()
			let size = vc.sizeThatFits(in: CGSize(width: .max, height: .max))
			NSLayoutConstraint.activate([
				vc.view.widthAnchor.constraint(equalToConstant: size.width),
				vc.view.heightAnchor.constraint(equalToConstant: min(44, size.height)),
			])
			
			barButtonItem!.customView = vc.view
		} else {
			vc = UIHostingController<AnyView>(rootView: view)
			vc!.view.backgroundColor = .clear
			vc!.view.translatesAutoresizingMaskIntoConstraints = false
			let size = vc!.sizeThatFits(in: CGSize(width: .max, height: .max))
			NSLayoutConstraint.activate([
				vc!.view.widthAnchor.constraint(equalToConstant: size.width),
				vc!.view.heightAnchor.constraint(equalToConstant: min(44, size.height)),
			])
			
			barButtonItem = UIBarButtonItem(customView: vc!.view)
			
			targetBarButtons([barButtonItem!])
		}
	}
	
	func handlePopupState(_ state: LNPopupState<PopupContent>) {
		currentPopupState = state
		
		let view = {
			state.content()
				.onPreferenceChange(LNPopupTitlePreferenceKey.self) { [weak self] titleData in
					self?.popupViewController?.popupItem.title = titleData?.title
					self?.popupViewController?.popupItem.subtitle = titleData?.subtitle
				}
				.onPreferenceChange(LNPopupImagePreferenceKey.self) { [weak self] image in
					self?.popupViewController?.popupItem.image = image
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
		
		target.popupBar.setValue(true, forKey: "_applySwiftUILayoutFixes")
		target.popupContentView.popupCloseButtonStyle = state.closeButtonStyle
		target.popupPresentationDelegate = self
		target.popupInteractionStyle = state.interactionStyle
		target.popupBar.barStyle = state.barStyle
		target.popupBar.progressViewStyle = state.barProgressViewStyle
		target.popupBar.marqueeScrollEnabled = state.barMarqueeScrollEnabled
		if state.isBarPresented == true {
			if popupViewController == nil {
				popupViewController = LNPopupUIContentController(rootView: view)
			} else {
				cast(value: popupViewController!, to: view.self).rootView = view
			}
			
			target.presentPopupBar(withContentViewController: popupViewController!, openPopup: state.isPopupOpen, animated: true, completion: nil)
		} else {
			target.dismissPopupBar(animated: true, completion: nil)
		}
	}
	
	override func addChild(_ childController: UIViewController) {
//		print("Child: \(target!)")
		super.addChild(childController)
		
		self.popupPresentationDelegate = nil
		if let state = currentPopupState, state.isBarPresented == true {
			dismissPopupBar(animated: false)
			childController.presentPopupBar(withContentViewController: self.popupViewController!, openPopup: state.isPopupOpen, animated: false, completion: nil)
			childController.popupPresentationDelegate = nil
		}
	}
	
	//MARK: LNPopupPresentationDelegate
	
	func popupPresentationControllerDidPresentPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isBarPresented = true
	}
	
	func popupPresentationControllerDidDismissPopupBar(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isBarPresented = false
	}
	
	func popupPresentationControllerDidOpenPopup(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isPopupOpen = true
	}
	
	func popupPresentationControllerDidClosePopup(_ popupPresentationController: UIViewController, animated: Bool) {
		currentPopupState?.isPopupOpen = false
	}
}
