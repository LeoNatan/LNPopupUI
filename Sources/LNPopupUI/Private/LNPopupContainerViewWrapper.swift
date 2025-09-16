//
//  LNPopupContainerViewWrapper.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupContainerViewWrapper<Content, PopupContent>: UIViewControllerRepresentable where Content: View, PopupContent: View {
	private var isBarPresented: Binding<Bool>
	private var isPopupOpen: Binding<Bool>?
	private let passthroughContent: () -> Content
	private let popupContent: (() -> PopupContent)?
	private let popupContentController: UIViewController?
	private let onOpen: (() -> Void)?
	private let onClose: (() -> Void)?
	
	init(isBarPresented: Binding<Bool>, isOpen: Binding<Bool>?, onOpen: (() -> Void)?, onClose: (() -> Void)?, popupContent: (() -> PopupContent)? = nil, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
		self.isBarPresented = isBarPresented
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
		
		let state = LNPopupState(isBarPresented: isBarPresented,
								 isPopupOpen: isPopupOpen,
								 inheritsAppearanceFromDockingView: context.environment.popupBarInheritsAppearanceFromDockingView,
								 inheritsEnvironmentFont: context.environment.popupBarInheritsEnvironmentFont,
								 inheritedFont: context.environment.uiFont,
								 interactionStyle: context.environment.popupInteractionStyle,
								 closeButtonStyle: context.environment.popupCloseButtonStyle,
								 barStyle: context.environment.popupBarStyle,
								 barBackgroundEffect: context.environment.popupBarBackgroundEffect,
								 barFloatingBackgroundEffect: context.environment.popupBarFloatingBackgroundEffect,
								 barFloatingBackgroundShadow: context.environment.popupBarFloatingBackgroundShadow,
								 barFloatingBackgroundCornerConfiguration: context.environment.popupBarFloatingBackgroundCornerConfiguration,
								 barImageShadow: context.environment.popupBarImageShadow,
								 barTitleTextAttributes: context.environment.popupBarTitleTextAttributes,
								 barSubtitleTextAttributes: context.environment.popupBarSubtitleTextAttributes,
								 barProgressViewStyle: context.environment.popupBarProgressViewStyle,
								 barMarqueeScrollEnabled: context.environment.popupBarMarqueeScrollEnabled,
								 customBarPrefersFullBarWidth: context.environment.popupBarCustomBarPrefersFullBarWidth,
								 hapticFeedbackEnabled: context.environment.popupHapticFeedbackEnabled,
								 limitFloatingContentWidth: context.environment.popupBarLimitFloatingContentWidth,
								 marqueeRate: context.environment.popupBarMarqueeRate,
								 marqueeDelay: context.environment.popupBarMarqueeDelay,
								 coordinateMarqueeAnimations: context.environment.popupBarCoordinateMarqueeAnimations,
								 shouldExtendPopupBarUnderSafeArea: context.environment.popupBarShouldExtendPopupBarUnderSafeArea,
								 customBarView: context.environment.popupBarCustomBarView,
								 contextMenu: context.environment.popupBarContextMenu,
								 content: popupContent,
								 contentController: popupContentController,
								 onOpen: onOpen,
								 onClose: onClose,
								 barCustomizer: context.environment.popupBarCustomizer,
								 contentViewCustomizer: context.environment.popupContentViewCustomizer)
		uiViewController.handlePopupState(state)
	}
}

internal extension LNPopupContainerViewWrapper where PopupContent == Never {
	init(isBarPresented: Binding<Bool>, isOpen: Binding<Bool>?, onOpen: (() -> Void)?, onClose: (() -> Void)?, popupContentController: UIViewController? = nil, @ViewBuilder content: @escaping () -> Content) {
		self.isBarPresented = isBarPresented
		self.isPopupOpen = isOpen
		passthroughContent = content
		self.popupContent = nil
		self.popupContentController = popupContentController
		self.onOpen = onOpen
		self.onClose = onClose
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
