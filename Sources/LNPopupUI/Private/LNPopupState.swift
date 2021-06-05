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
	@Binding var isPopupOpen: Bool
	let interactionStyle: LNPopupInteractionStyle
	let closeButtonStyle: LNPopupCloseButtonStyle
	let barStyle: LNPopupBarStyle
	let barBackgroundStyle: UIBlurEffect.Style
	let barProgressViewStyle: LNPopupBarProgressViewStyle
	let barMarqueeScrollEnabled: Bool?
	let marqueeRate: CGFloat?
	let marqueeDelay: TimeInterval?
	let coordinateMarqueeAnimations: Bool?
	let popupBarShouldExtendPopupBarUnderSafeArea: Bool
	let customBarView: LNPopupBarCustomView?
	let contextMenu: AnyView?
	let content: (() -> PopupContent)?
	let contentController: UIViewController?
	let onOpen: (() -> Void)?
	let onClose: (() -> Void)?
	let barCustomizer: ((LNPopupBar) -> Void)?
	let contentViewCustomizer: ((LNPopupContentView) -> Void)?
}
