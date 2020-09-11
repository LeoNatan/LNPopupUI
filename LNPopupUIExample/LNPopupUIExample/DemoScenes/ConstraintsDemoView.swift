//
//  SafeAreaDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LNPopupUI
import LoremIpsum

struct SafeAreaDemoView : View {
	let includeLink: Bool
	let offset: Bool
	
	init(includeLink: Bool = false, offset: Bool = false) {
		self.includeLink = includeLink
		self.offset = offset
	}
	
	var body: some View {
		ZStack(alignment: .trailing) {
			VStack {
				Text("Top").offset(x: offset ? 40.0 : 0.0)
				Spacer()
				Text("Center")
				Spacer()
				Text("Bottom")
			}.frame(minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					maxHeight: .infinity,
					alignment: .top)
			if includeLink {
				NavigationLink("Next ▸", destination: SafeAreaDemoView(includeLink: includeLink).navigationTitle("LNPopupUI"))
					.padding()
			}
		}
		.padding(4)
		.font(.system(.headline))
	}
}

extension View {
	func popupDemo(isBarPresented: Binding<Bool>) -> some View {
		return self.popup(isBarPresented: isBarPresented, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			SafeAreaDemoView(offset: true)
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
//		.popupCloseButtonStyle(.round)
//		.popupInteractionStyle(.drag)
	}
}
