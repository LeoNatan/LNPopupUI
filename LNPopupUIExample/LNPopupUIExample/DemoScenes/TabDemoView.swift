//
//  TabDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct InnerView : View {
	let tabIdx: Int?
	let onDismiss: () -> Void
	
	init(tabIdx: Int? = nil, onDismiss: @escaping ()-> Void) {
		self.tabIdx = tabIdx
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			SafeAreaDemoView(colorSeed: tabIdx != nil ? "tab_\(tabIdx!)" : "nil")
			Button("Gallery") {
				onDismiss()
			}.padding()
		}
	}
}

struct TabDemoView : View {
	@State private var isBarPresented: Bool = true
	private let onDismiss: () -> Void
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		self.demoContent = demoContent
	}
	
	var body: some View {
		TabView{
			InnerView(tabIdx:0, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:1, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:2, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:3, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:4, onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented)
	}
}

struct TabDemoView_Previews: PreviewProvider {
	static var previews: some View {
		TabDemoView(demoContent: DemoContent(), onDismiss: {})
	}
}
