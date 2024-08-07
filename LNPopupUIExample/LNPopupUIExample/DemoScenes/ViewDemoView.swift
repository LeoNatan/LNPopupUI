//
//  ViewDemoView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct ViewDemoView : View {
	@State private var isBarPresented: Bool = true
	let onDismiss: () -> Void
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		self.demoContent = demoContent
	}
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		InnerView(tabIdx:nil, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
			.popupDemo(demoContent:demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
	}
}

struct ViewDemoView_Previews: PreviewProvider {
	static var previews: some View {
		ViewDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
