//
//  ViewDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct ViewDemoView : View {
	@State private var isPopupPresented: Bool = true
	let onDismiss: () -> Void
	let contextMenu: Bool
	
	init(contextMenu: Bool = false, onDismiss: @escaping () -> Void) {
		self.contextMenu = contextMenu
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		InnerView(onDismiss: onDismiss)
			.popupDemo(isBarPresented: $isPopupPresented, includeContextMenu: contextMenu)
	}
}
