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
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			ConstraintsDemoView(includeLink: false)
			Button("Gallery") {
				onDismiss()
			}.padding()
		}
	}
}

struct TabDemoView : View {
	@State private var isPopupPresented: Bool = true
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		TabView{
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(onDismiss: onDismiss)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}
		.popup(isBarPresented: $isPopupPresented, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			ZStack {
				Color.red.ignoresSafeArea()
				ConstraintsDemoView(includeLink: false)
			}
			.popupTitle(LoremIpsum.title, subtitle: LoremIpsum.sentence)
			.popupImage(Image("genre\(Int.random(in: 1..<31))"))
			.popupBarItems({
				HStack(spacing: 20) {
					Button(action: {
						print("Play")
					}) {
						Image(systemName: "play.fill")
					}
					
					Button(action: {
						print("Next")
					}) {
						Image(systemName: "forward.fill")
					}
				}
				.font(.system(size: 20))
			})
		}
		.popupCloseButtonStyle(.round)
	}
}
