//
//  SafeAreaDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI
import LNPopupUI
import LoremIpsum

extension View {
	@ViewBuilder
	func ifLet<V, Transform: View>(
		_ value: V?,
		transform: (Self, V) -> Transform
	) -> some View {
		if let value = value {
			transform(self, value)
		} else {
			self
		}
	}
	
	@ViewBuilder
	func `if`<Transform: View>(
		_ value: Bool,
		transform: (Self) -> Transform
	) -> some View {
		if value {
			transform(self)
		} else {
			self
		}
	}
}

struct SafeAreaDemoView : View {
	let includeLink: Bool
	let offset: Bool
	let onDismiss: (() -> Void)?
	let colorSeed: String
	let colorIndex: Int
	
	init(colorSeed: String = "nil", colorIndex: Int = 0, includeLink: Bool = false, offset: Bool = false, onDismiss: (() -> Void)? = nil) {
		self.includeLink = includeLink
		self.offset = offset
		self.onDismiss = onDismiss
		self.colorSeed = colorSeed
		self.colorIndex = colorIndex
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
				NavigationLink("Next ▸", destination: SafeAreaDemoView(colorSeed: colorSeed, colorIndex: colorIndex + 1, includeLink: includeLink, onDismiss: onDismiss).navigationTitle("LNPopupUI"))
					.padding()
			}
		}
		.padding(4)
		.background(Color(UIColor.adaptiveColor(withSeed: "\(colorSeed)\(colorIndex > 0 ? String(colorIndex) : "")")).edgesIgnoringSafeArea(.all))
		.font(.system(.headline))
		.ifLet(onDismiss) { view, onDismiss in
			view.navigationBarItems(trailing: Button("Gallery") {
				onDismiss()
			})
		}
	}
}

//return view

extension View {
	func popupDemo(isBarPresented: Binding<Bool>, includeContextMenu: Bool = false) -> some View {
		return self.popup(isBarPresented: isBarPresented, onOpen: { print("Opened") }, onClose: { print("Closed") }) {
			SafeAreaDemoView(colorSeed: "Popup", offset: true)
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
//		.popupInteractionStyle(.drag)
		.if(includeContextMenu) { view in
			view.popupBarContextMenu {
				Button(action: {
					print("Context Menu Item 1")
				}) {
					Text("Context Menu Item 1")
					Image(systemName: "globe")
				}
				
				Button(action: {
					print("Context Menu Item 2")
				}) {
					Text("Context Menu Item 2")
					Image(systemName: "location.circle")
				}
			}
		}
	}
}
