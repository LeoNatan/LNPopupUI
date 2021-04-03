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
	@State private var isBarPresented: Bool = true
	@State private var isPopupOpen: Bool = false
	let onDismiss: () -> Void
	let contextMenu: Bool
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, contextMenu: Bool = false, onDismiss: @escaping () -> Void) {
		self.contextMenu = contextMenu
		self.onDismiss = onDismiss
		self.demoContent = demoContent
	}
	
	var body: some View {
		InnerView(onDismiss: onDismiss)
			.popupDemo(demoContent:demoContent, isBarPresented: $isBarPresented, isPopupOpen: $isPopupOpen, includeContextMenu: contextMenu)
	}
}

struct ViewDemoView_Previews: PreviewProvider {
	static var previews: some View {
		ViewDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
