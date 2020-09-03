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
	let barProgressViewStyle: LNPopupBarProgressViewStyle
	let barMarqueeScrollEnabled: Bool
	let customBarView: LNPopupBarCustomView?
	let content: () -> PopupContent
}
