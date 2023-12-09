//
//  LNPopupState.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
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

internal struct LNPopupState<PopupContent: View> {
	@Binding var isBarPresented: Bool
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
}
