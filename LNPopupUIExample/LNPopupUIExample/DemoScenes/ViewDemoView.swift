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
	
	var body: some View {
		InnerView(onDismiss: onDismiss)
			.popupDemo(isBarPresented: $isPopupPresented)
	}
}
