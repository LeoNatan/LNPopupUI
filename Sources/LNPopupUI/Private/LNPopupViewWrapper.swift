//
//  LNPopupViewWrapper.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//  
//

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupViewWrapper<Content, PopupContent>: UIViewControllerRepresentable where Content: View, PopupContent: View {
	@Binding private var isBarPresented: Bool
	@Binding private var isPopupOpen: Bool
	private let passthroughContent: () -> Content
	private let popupContent: () -> PopupContent
	
	@Environment(\.popupInteractionStyle) var popupInteractionStyle: LNPopupInteractionStyle
	@Environment(\.popupCloseButtonStyle) var popupCloseButtonStyle: LNPopupCloseButtonStyle
	@Environment(\.popupBarStyle) var popupBarStyle: LNPopupBarStyle
	@Environment(\.popupBarProgressViewStyle) var popupBarProgressViewStyle: LNPopupBarProgressViewStyle
	@Environment(\.popupBarMarqueeScrollEnabled) var popupBarMarqueeScrollEnabled: Bool
	
	init(isBarPresented: Binding<Bool>, isOpen: Binding<Bool>, popupContent: @escaping () -> PopupContent, @ViewBuilder content: @escaping () -> Content) {
		self._isBarPresented = isBarPresented
		self._isPopupOpen = isOpen
		passthroughContent = content
		self.popupContent = popupContent
	}
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<LNPopupViewWrapper>) -> LNPopupProxyViewController<Content, PopupContent> {
		return LNPopupProxyViewController(rootView: passthroughContent())
	}
	
	func updateUIViewController(_ uiViewController: LNPopupProxyViewController<Content, PopupContent>, context: UIViewControllerRepresentableContext<LNPopupViewWrapper>) {
		
		uiViewController.rootView = passthroughContent()
		
		let state = LNPopupState(isBarPresented: _isBarPresented,
								 isPopupOpen: _isPopupOpen,
								 interactionStyle: popupInteractionStyle,
								 closeButtonStyle: popupCloseButtonStyle,
								 barStyle: popupBarStyle,
								 barProgressViewStyle: popupBarProgressViewStyle,
								 barMarqueeScrollEnabled: popupBarMarqueeScrollEnabled,
								 content: popupContent)
		uiViewController.handlePopupState(state)
	}
}
