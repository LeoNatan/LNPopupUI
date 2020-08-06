//
//  LNPopupState.swift
//  LNPopupUI
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import UIKit
import LNPopupController

internal struct LNPopupState<PopupContent: View> {
	@Binding var isBarPresented: Bool
	@Binding var isPopupOpen: Bool
	let interactionStyle: LNPopupInteractionStyle
	let barStyle: LNPopupBarStyle
	let barProgressViewStyle: LNPopupBarProgressViewStyle
	let barMarqueeScrollEnabled: Bool
	let content: () -> PopupContent
}
