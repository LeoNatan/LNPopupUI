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
			.tint(Color(.label))
	}
}

struct SceneSelection: View {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
	@State var tabnavPresented: Bool = false
	@State var tabPresented: Bool = false
	@State var tabCustomPresented: Bool = false
	@State var navPresented: Bool = false
	@State var viewPresented: Bool = false
	@State var viewSheetPresented: Bool = false
	@State var compactSliderSheetPresented: Bool = false
	@State var musicSheetPresented: Bool = false
	@State var mapSheetPresented: Bool = false
	@State var splitViewPresented: Bool = false
	@State var splitViewGlobalPresented: Bool = false
	
	@State var settingsPresented: Bool = false
	@State private var item: ActivityItem? = nil
	
	@AppStorage(DemoAppEnableFunkyInheritedFont) var enableFunkyInheritedFont: Bool = false
	@AppStorage(DemoAppEnableExternalScenes) var enableExternalScenes: Bool = false
	
	let font = Font.custom("Chalkduster", size: 15)
//	let font = Font.custom("Avenir Next", fixedSize: 15).weight(.heavy).italic()
//	let font = Font.custom("Zapfino", size: 15).italic().weight(.heavy).width(.condensed)
//	let font = Font.system(size: 15, weight: .regular)
//	let font = Font.system(size: 15, weight: .regular).monospacedDigit()
//	let font = Font.system(size: 15, weight: .black).monospaced().lowercaseSmallCaps()
	
	var body: some View {
		MaterialNavigationStack {
			List {
				Section {
					CellPaddedButton("Tab View + Navigation View") {
						tabnavPresented.toggle()
					}
					.fullScreenCover(isPresented: $tabnavPresented, content: {
						TabNavView(demoContent: DemoContent()) {
							tabnavPresented.toggle()
						}
					})
					CellPaddedButton("Tab View") {
						tabPresented.toggle()
					}
					.fullScreenCover(isPresented: $tabPresented, content: {
						TabDemoView(demoContent: DemoContent()) {
							tabPresented.toggle()
						}
					})
					CellPaddedButton("Tab View (Custom Labels)") {
						tabCustomPresented.toggle()
					}
					.fullScreenCover(isPresented: $tabCustomPresented, content: {
						TabViewCustomLabels(demoContent: DemoContent()) {
							tabCustomPresented.toggle()
						}
					})
					CellPaddedButton("Navigation View") {
						navPresented.toggle()
					}
					.fullScreenCover(isPresented: $navPresented, content: {
						NavDemoView(demoContent: DemoContent()) {
							navPresented.toggle()
						}
					})
					CellPaddedButton("Navigation View (Sheet)") {
						viewSheetPresented.toggle()
					}
					.sheet(isPresented: $viewSheetPresented, content: {
						NavDemoView(demoContent: DemoContent()) {
							viewSheetPresented.toggle()
						}
					})
					CellPaddedButton("View") {
						viewPresented.toggle()
					}
					.fullScreenCover(isPresented: $viewPresented, content: {
						ViewDemoView(demoContent: DemoContent()) {
							viewPresented.toggle()
						}
					})
					Group {
						CellPaddedButton("Split View (All)") {
							splitViewPresented.toggle()
						}.fullScreenCover(isPresented: $splitViewPresented) {
							SplitDemoView(isGlobal: false) {
								splitViewPresented.toggle()
							}
						}
						CellPaddedButton("Split View (Global)") {
							splitViewGlobalPresented.toggle()
						}
						.fullScreenCover(isPresented: $splitViewGlobalPresented) {
							SplitDemoView(isGlobal: true) {
								splitViewGlobalPresented.toggle()
							}
						}
					}
					.disabled(horizontalSizeClass == .compact)
					.onChange(of: horizontalSizeClass) { newValue in
						if newValue == .compact {
							splitViewPresented = false
							splitViewGlobalPresented = false
						}
					}
				} header: {
					Text("Standard Scenes")
				} footer: {
					Text("Presents a standard test scene with a popup bar.")
				}
				Section {
					CellPaddedButton("Music") {
						musicSheetPresented.toggle()
					}
					.fullScreenCover(isPresented: $musicSheetPresented, content: {
						MusicView {
							musicSheetPresented.toggle()
						}
					})
				} header: {
					Text("Demo Apps")
				} footer: {
					Text("Presents a rudimentary recreation of a music app.")
				}
				Section {
					CellPaddedButton("Custom Popup Bar") {
						mapSheetPresented.toggle()
					}
					.fullScreenCover(isPresented: $mapSheetPresented, content: {
						CustomBarMapView {
							mapSheetPresented.toggle()
						}
					})
				} header: {
					Text("Custom Popup Bar")
				} footer: {
					Text("Presents a scene with a custom popup bar view and a UIKit popup content controller")
				}
				
				if enableExternalScenes {
					Section {
						CellPaddedButton("CompactSlider") {
							compactSliderSheetPresented.toggle()
						}
						.fullScreenCover(isPresented: $compactSliderSheetPresented, content: {
							CompactSliderDemoView {
								compactSliderSheetPresented.toggle()
							}
						})
					} header: {
						Text("External Libraries—Gestures")
					} footer: {
						Text("Presents a popup content view with [CompactSlider](https://github.com/buh/CompactSlider) elements, to test gesture handling in the library.")
					}
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
