//
//  LNPopupState.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupBarCustomView {
	let wantsDefaultTapGesture: Bool
	let wantsDefaultPanGesture: Bool
	let wantsDefaultHighlightGesture: Bool
	let popupBarCustomBarView: AnyView
}

typealias LNPopupSmallState = (isBarPresented: Bool, isPopupOpen: Bool?)

internal struct LNPopupState<PopupContent: View> {
	var isBarPresented: Binding<Bool>
	var isPopupOpen: Binding<Bool>?
	let inheritsAppearanceFromDockingView: LNPopupEnvironmentConsumer<Bool>?
	let inheritsEnvironmentFont: LNPopupEnvironmentConsumer<Bool>?
	let inheritedFont: UIFont?
	let interactionStyle: LNPopupEnvironmentConsumer<UIViewController.PopupInteractionStyle>?
	let closeButtonStyle: LNPopupEnvironmentConsumer<LNPopupCloseButton.Style>?
	let barStyle: LNPopupEnvironmentConsumer<LNPopupBar.Style>?
	let barBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>?
	let barFloatingBackgroundEffect: LNPopupEnvironmentConsumer<UIBlurEffect>?
	let barFloatingBackgroundShadow: LNPopupEnvironmentConsumer<NSShadow>?
	let barImageShadow: LNPopupEnvironmentConsumer<NSShadow>?
	let barTitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	let barSubtitleTextAttributes: LNPopupEnvironmentConsumer<Any>?
	let barProgressViewStyle: LNPopupEnvironmentConsumer<LNPopupBar.ProgressViewStyle>?
	let barMarqueeScrollEnabled: LNPopupEnvironmentConsumer<Bool>?
	let hapticFeedbackEnabled: LNPopupEnvironmentConsumer<Bool>?
	let limitFloatingContentWidth: LNPopupEnvironmentConsumer<Bool>?
	let marqueeRate: LNPopupEnvironmentConsumer<CGFloat>?
	let marqueeDelay: LNPopupEnvironmentConsumer<TimeInterval>?
	let coordinateMarqueeAnimations: LNPopupEnvironmentConsumer<Bool>?
	let shouldExtendPopupBarUnderSafeArea: LNPopupEnvironmentConsumer<Bool>?
	let customBarView: LNPopupEnvironmentConsumer<LNPopupBarCustomView>?
	let contextMenu: LNPopupEnvironmentConsumer<AnyView>?
	let content: (() -> PopupContent)?
	let contentController: UIViewController?
	let onOpen: (() -> Void)?
	let onClose: (() -> Void)?
	let barCustomizer: LNPopupEnvironmentConsumer<((LNPopupBar) -> Void)>?
	let contentViewCustomizer: LNPopupEnvironmentConsumer<((LNPopupContentView) -> Void)>?
	
	var smallState: LNPopupSmallState {
		return (isBarPresented.wrappedValue, isPopupOpen?.wrappedValue)
	}
}
