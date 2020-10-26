//
//  SceneSelection.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/2/20.
//

import SwiftUI
import LNPopupUI

fileprivate let introWebController = WebController()

struct SceneSelection: View {
	@State var tabnavPresented: Bool = false
	@State var tabPresented: Bool = false
	@State var navPresented: Bool = false
	@State var viewPresented: Bool = false
	@State var viewSheetPresented: Bool = false
	@State var musicSheetPresented: Bool = false
	@State var mapSheetPresented: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Standard Scenes (Chevron + Snap)").frame(height: 48, alignment: .bottom)) {
					Button("Tab View + Navigation View") {
						tabnavPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $tabnavPresented, content: {
						TabNavView {
							tabnavPresented.toggle()
						}
					})
					Button("Tab View") {
						tabPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $tabPresented, content: {
						TabDemoView {
							tabPresented.toggle()
						}
					})
					Button("Navigation View") {
						navPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $navPresented, content: {
						NavDemoView {
							navPresented.toggle()
						}
					})
					Button("Navigation View (Sheet)") {
						viewSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.sheet(isPresented: $viewSheetPresented, content: {
						NavDemoView {
							viewSheetPresented.toggle()
						}
					})
					Button("View") {
						viewPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $viewPresented, content: {
						ViewDemoView() {
							viewPresented.toggle()
						}
					})
				}
				Section(header: Text("Demo App")) {
					Button("Apple Music") {
						musicSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $musicSheetPresented, content: {
						MusicView {
							musicSheetPresented.toggle()
						}
					})
				}
				Section(header: Text("Custom Popup Bar")) {
					Button("Custom Popup Bar + UIKit Popup Content Controller") {
						mapSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $mapSheetPresented, content: {
						CustomBarMapView {
							mapSheetPresented.toggle()
						}
					})
				}
			}
			.listStyle(GroupedListStyle())
			.navigationBarTitle("LNPopupUI")
			.navigationBarTitleDisplayMode(.inline)
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.ignoresSafeArea()
		.popup(isBarPresented: Binding.constant(true), popupContentController: introWebController)
		.popupCloseButtonStyle(.none)
		.popupBarMarqueeScrollEnabled(true)
	}
}

struct SceneSelection_Previews: PreviewProvider {
	static var previews: some View {
		SceneSelection()
		
	}
}
