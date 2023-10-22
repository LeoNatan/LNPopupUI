//
//  SceneSelection.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/2/20.
//

import SwiftUI
import LNPopupUI
import ActivityView

fileprivate struct CellPaddedButton<S: StringProtocol>: View {
	let text: S
	let action: () -> Void
	
	public init(_ content: S, action: @escaping () -> Void) {
		text = content
		self.action = action
	}
	
	var body: some View {
		Button(text, action: action).padding([.top, .bottom], 4.167)
	}
}

struct SceneSelection: View {
	@State var tabnavPresented: Bool = false
	@State var tabPresented: Bool = false
	@State var tabCustomPresented: Bool = false
	@State var navPresented: Bool = false
	@State var viewPresented: Bool = false
	@State var viewSheetPresented: Bool = false
	@State var compactSliderSheetPresented: Bool = false
	@State var musicSheetPresented: Bool = false
	@State var mapSheetPresented: Bool = false
	
	@State var settingsPresented: Bool = false
	@State private var item: ActivityItem? = nil
	
	@AppStorage(DemoAppEnableFunkyInheritedFont) var enableFunkyInheritedFont: Bool = false
	
	let font = Font.custom("Chalkduster", size: 15)
//	let font = Font.custom("Avenir Next", fixedSize: 15).weight(.heavy).italic()
//	let font = Font.custom("Zapfino", size: 15).italic().weight(.heavy).width(.condensed)
//	let font = Font.system(size: 15, weight: .regular)
//	let font = Font.system(size: 15, weight: .regular).monospacedDigit()
//	let font = Font.system(size: 15, weight: .black).monospaced().lowercaseSmallCaps()
//	let font: Font? = nil
	
	var body: some View {
		NavigationStack {
			List {
				Section(header: Text("Standard Scenes"), footer: Text("Presents a standard test scene with a popup bar.")) {
					CellPaddedButton("Tab View + Navigation View") {
						tabnavPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $tabnavPresented, content: {
						TabNavView(demoContent: DemoContent()) {
							tabnavPresented.toggle()
						}
					})
					CellPaddedButton("Tab View") {
						tabPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $tabPresented, content: {
						TabDemoView(demoContent: DemoContent()) {
							tabPresented.toggle()
						}
					})
					CellPaddedButton("Tab View (Custom Labels)") {
						tabCustomPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $tabCustomPresented, content: {
						TabViewCustomLabels(demoContent: DemoContent()) {
							tabCustomPresented.toggle()
						}
					})
					CellPaddedButton("Navigation View") {
						navPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $navPresented, content: {
						NavDemoView(demoContent: DemoContent()) {
							navPresented.toggle()
						}
					})
					CellPaddedButton("Navigation View (Sheet)") {
						viewSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.sheet(isPresented: $viewSheetPresented, content: {
						NavDemoView(demoContent: DemoContent()) {
							viewSheetPresented.toggle()
						}
					})
					CellPaddedButton("View") {
						viewPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $viewPresented, content: {
						ViewDemoView(demoContent: DemoContent()) {
							viewPresented.toggle()
						}
					})
				}
				Section(header: Text("Demo Apps"), footer: Text("Presents a rudimentary recreation of a music app.")) {
					CellPaddedButton("Music") {
						musicSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $musicSheetPresented, content: {
						MusicView {
							musicSheetPresented.toggle()
						}
					})
				}
				Section(header: Text("Custom Popup Bar"), footer: Text("Presents a scene with a custom popup bar view and a UIKit popup content controller")) {
					CellPaddedButton("Custom Popup Bar") {
						mapSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $mapSheetPresented, content: {
						CustomBarMapView {
							mapSheetPresented.toggle()
						}
					})
				}
				Section(header: Text("Gestures"), footer: Text("Presents a popup content view with [CompactSlider](https://github.com/buh/CompactSlider) elements, to test gesture handling in the library.")) {
					CellPaddedButton("CompactSlider") {
						compactSliderSheetPresented.toggle()
					}
					.foregroundColor(Color(.label))
					.fullScreenCover(isPresented: $compactSliderSheetPresented, content: {
						CompactSliderDemoView {
							compactSliderSheetPresented.toggle()
						}
					})
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("LNPopupUI")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						settingsPresented.toggle()
					} label: {
						Image("gears")
					}
					.popover(isPresented: $settingsPresented, content: {
						SettingsNavView()
					})
				}
			}
			.navigationBarTitleDisplayMode(.inline)
		}
		.popup(isBarPresented: Binding.constant(true), popupContent: {
			PopupDemoWebView()
		})
		.popupBarStyle(.floating)
		.popupBarContextMenu {
			Link(destination: URL(string: "https://github.com/LeoNatan/LNPopupUI")!) {
				Text("Visit GitHub Page")
				Image(systemName: "safari")
			}
			Link(destination: URL(string: "https://github.com/LeoNatan/LNPopupUI/issues/new/choose")!) {
				Text("Report an Issue…")
				Image(systemName: "ant.fill")
			}
			Divider()
			Button {
				item = ActivityItem(
					items: URL(string: "https://github.com/LeoNatan/LNPopupUI")!
				)
			} label: {
				Text("Share…")
				Image(systemName: "square.and.arrow.up")
			}

		}
		.activitySheet($item)
		.font(enableFunkyInheritedFont ? font : nil)
	}
}

struct SceneSelection_Previews: PreviewProvider {
	static var previews: some View {
		SceneSelection()
	}
}
