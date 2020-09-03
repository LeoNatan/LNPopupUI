//
//  SceneSelection.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/2/20.
//

import SwiftUI

struct SceneSelection: View {
	@State var musicSheetPresented: Bool = false
	@State var mapSheetPresented: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Demo App").frame(height: 48, alignment: .bottom)) {
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
					Button("Custom Popup Bar with SwiftUI") {
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
	}
}

struct SceneSelection_Previews: PreviewProvider {
	static var previews: some View {
		SceneSelection()
		
	}
}
