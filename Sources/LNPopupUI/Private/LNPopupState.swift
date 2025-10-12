//
//  LNPopupState.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
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
	let environment: EnvironmentValues
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
