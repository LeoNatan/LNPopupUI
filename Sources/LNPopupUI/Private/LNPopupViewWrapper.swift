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
	private let popupContent: (() -> PopupContent)?
	private let popupContentController: UIViewController?
	private let onOpen: (() -> Void)?
	private let onClose: (() -> Void)?
	
	@Environment(\.popupInteractionStyle) var popupInteractionStyle: LNPopupInteractionStyle
	@Environment(\.popupCloseButtonStyle) var popupCloseButtonStyle: LNPopupCloseButtonStyle
	@Environment(\.popupBarStyle) var popupBarStyle: LNPopupBarStyle
	@Environment(\.popupBarProgressViewStyle) var popupBarProgressViewStyle: LNPopupBarProgressViewStyle
	@Environment(\.popupBarMarqueeScrollEnabled) var popupBarMarqueeScrollEnabled: Bool?
	@Environment(\.popupBarMarqueeRate) var popupBarMarqueeRate: CGFloat?
	@Environment(\.popupBarMarqueeDelay) var popupBarMarqueeDelay: TimeInterval?
	@Environment(\.popupBarCoordinateMarqueeAnimations) var popupBarCoordinateMarqueeAnimations: Bool?
	@Environment(\.popupBarShouldExtendPopupBarUnderSafeArea) var popupBarShouldExtendPopupBarUnderSafeArea: Bool
	@Environment(\.popupBarBackgroundStyle) var popupBarBackgroundStyle: UIBlurEffect.Style?
	@Environment(\.popupBarCustomBarView) var popupBarCustomBarView: LNPopupBarCustomView?
	@Environment(\.popupBarContextMenu) var popupBarContextMenu: AnyView?
	@Environment(\.popupBarCustomizer) var popupBarCustomizer: ((LNPopupBar) -> Void)?
	@Environment(\.popupContentViewCustomizer) var popupContentViewCustomizer: ((LNPopupContentView) -> Void)?
	
	init(isBarPresented: Binding<Bool>, isOpen: Binding<Bool>, onOpen: (() -> Void)?, onClose: (() -> Void)?, popupContent: (() -> PopupContent)? = nil, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
		self._isBarPresented = isBarPresented
		self._isPopupOpen = isOpen
		passthroughContent = content
		self.popupContent = popupContent
		self.popupContentController = popupContentController
		self.onOpen = onOpen
		self.onClose = onClose
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
								 barBackgroundStyle: popupBarBackgroundStyle ?? LNBackgroundStyleInherit,
								 barProgressViewStyle: popupBarProgressViewStyle,
								 barMarqueeScrollEnabled: popupBarMarqueeScrollEnabled,
								 marqueeRate: popupBarMarqueeRate,
								 marqueeDelay: popupBarMarqueeDelay,
								 coordinateMarqueeAnimations: popupBarCoordinateMarqueeAnimations,
								 popupBarShouldExtendPopupBarUnderSafeArea: popupBarShouldExtendPopupBarUnderSafeArea,
								 customBarView: popupBarCustomBarView,
								 contextMenu: popupBarContextMenu,
								 content: popupContent,
								 contentController: popupContentController,
								 onOpen: onOpen,
								 onClose: onClose,
								 barCustomizer: popupBarCustomizer,
								 contentViewCustomizer: popupContentViewCustomizer)
		uiViewController.handlePopupState(state)
	}
}

internal class LNPopupUIInteractionContainerView : UIView {
}

internal struct LNPopupUIInteractionContainerBackgroundView : UIViewRepresentable {
	func makeUIView(context: Context) -> LNPopupUIInteractionContainerView {
		return LNPopupUIInteractionContainerView()
	}
	
	func updateUIView(_ uiView: LNPopupUIInteractionContainerView, context: Context) { }
}
