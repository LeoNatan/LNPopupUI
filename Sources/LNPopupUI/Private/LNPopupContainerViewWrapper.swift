//
//  LNPopupContainerViewWrapper.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//  
//

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupContainerViewWrapper<Content, PopupContent>: UIViewControllerRepresentable where Content: View, PopupContent: View {
	@Binding private var isBarPresented: Bool
	private var isPopupOpen: Binding<Bool>?
	private let passthroughContent: () -> Content
	private let popupContent: (() -> PopupContent)?
	private let popupContentController: UIViewController?
	private let onOpen: (() -> Void)?
	private let onClose: (() -> Void)?
	
	@Environment(\.font) var inheritedFont
	@Environment(\.popupBarInheritsAppearanceFromDockingView) var popupBarInheritsAppearanceFromDockingView: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupBarInheritsEnvironmentFont) var popupBarInheritsEnvironmentFont: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupInteractionStyle) var popupInteractionStyle: LNPopupEnvironmentConsumer<UIViewController.PopupInteractionStyle>?
	@Environment(\.popupCloseButtonStyle) var popupCloseButtonStyle: LNPopupEnvironmentConsumer<LNPopupCloseButton.Style>?
	@Environment(\.popupBarStyle) var popupBarStyle: LNPopupEnvironmentConsumer<LNPopupBar.Style>?
	@Environment(\.popupBarProgressViewStyle) var popupBarProgressViewStyle: LNPopupEnvironmentConsumer<LNPopupBar.ProgressViewStyle>?
	@Environment(\.popupBarMarqueeScrollEnabled) var popupBarMarqueeScrollEnabled: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupHapticFeedbackEnabled) var popupHapticFeedbackEnabled: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupBarMarqueeRate) var popupBarMarqueeRate: LNPopupEnvironmentConsumer<CGFloat>?
	@Environment(\.popupBarMarqueeDelay) var popupBarMarqueeDelay: LNPopupEnvironmentConsumer<TimeInterval>?
	@Environment(\.popupBarCoordinateMarqueeAnimations) var popupBarCoordinateMarqueeAnimations: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupBarShouldExtendPopupBarUnderSafeArea) var popupBarShouldExtendPopupBarUnderSafeArea: LNPopupEnvironmentConsumer<Bool>?
	@Environment(\.popupBarBackgroundEffect) var popupBarBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>?
	@Environment(\.popupBarFloatingBackgroundEffect) var popupBarFloatingBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>?
	@Environment(\.popupBarFloatingBackgroundShadow) var popupBarFloatingBackgroundShadow: LNPopupEnvironmentConsumer<NSShadow>?
	@Environment(\.popupBarImageShadow) var popupBarImageShadow: LNPopupEnvironmentConsumer<NSShadow>?
	@Environment(\.popupBarTitleTextAttributes) var popupBarTitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	@Environment(\.popupBarSubtitleTextAttributes) var popupBarSubtitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	@Environment(\.popupBarCustomBarView) var popupBarCustomBarView: LNPopupEnvironmentConsumer<LNPopupBarCustomView>?
	@Environment(\.popupBarContextMenu) var popupBarContextMenu: LNPopupEnvironmentConsumer<AnyView>?
	@Environment(\.popupBarCustomizer) var popupBarCustomizer: LNPopupEnvironmentConsumer<((LNPopupBar) -> Void)>?
	@Environment(\.popupContentViewCustomizer) var popupContentViewCustomizer: LNPopupEnvironmentConsumer<((LNPopupContentView) -> Void)>?
	
	init(isBarPresented: Binding<Bool>, isOpen: Binding<Bool>?, onOpen: (() -> Void)?, onClose: (() -> Void)?, popupContent: (() -> PopupContent)? = nil, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
		self._isBarPresented = isBarPresented
		self.isPopupOpen = isOpen
		passthroughContent = content
		self.popupContent = popupContent
		self.popupContentController = popupContentController
		self.onOpen = onOpen
		self.onClose = onClose
	}
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<LNPopupContainerViewWrapper>) -> LNPopupProxyViewController<Content, PopupContent> {
		return LNPopupProxyViewController(rootView: passthroughContent())
	}
	
	func updateUIViewController(_ uiViewController: LNPopupProxyViewController<Content, PopupContent>, context: UIViewControllerRepresentableContext<LNPopupContainerViewWrapper>) {
		
		uiViewController.rootView = passthroughContent()
		
		let state = LNPopupState(isBarPresented: _isBarPresented,
								 isPopupOpen: isPopupOpen,
								 inheritsAppearanceFromDockingView: popupBarInheritsAppearanceFromDockingView,
								 inheritsEnvironmentFont: popupBarInheritsEnvironmentFont,
								 inheritedFont: inheritedFont?.uiFont,
								 interactionStyle: popupInteractionStyle,
								 closeButtonStyle: popupCloseButtonStyle,
								 barStyle: popupBarStyle,
								 barBackgroundEffect: popupBarBackgroundEffect,
								 barFloatingBackgroundEffect: popupBarFloatingBackgroundEffect,
								 barFloatingBackgroundShadow: popupBarFloatingBackgroundShadow,
								 barImageShadow: popupBarImageShadow,
								 barTitleTextAttributes: popupBarTitleTextAttributes,
								 barSubtitleTextAttributes: popupBarSubtitleTextAttributes,
								 barProgressViewStyle: popupBarProgressViewStyle,
								 barMarqueeScrollEnabled: popupBarMarqueeScrollEnabled,
								 hapticFeedbackEnabled: popupHapticFeedbackEnabled,
								 marqueeRate: popupBarMarqueeRate,
								 marqueeDelay: popupBarMarqueeDelay,
								 coordinateMarqueeAnimations: popupBarCoordinateMarqueeAnimations,
								 shouldExtendPopupBarUnderSafeArea: popupBarShouldExtendPopupBarUnderSafeArea,
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
