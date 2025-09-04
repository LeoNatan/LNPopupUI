//
//  SceneSelection.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-04.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNPopupUI
import ActivityView

fileprivate struct CellPaddedButton: View {
	let text: LocalizedStringKey
	let action: () -> Void
	
	public init(_ content: LocalizedStringKey, action: @escaping () -> Void) {
		text = content
		self.action = action
	}
	
	var body: some View {
		Button(text, action: action)
//			.padding([.top, .bottom], 4.167)
			.tint(Color(.label))
	}
}

fileprivate struct LNHeaderFooterView: View {
	let content: Text
	public init(_ content: String) {
		self.content = Text(content)
	}
	
	var body: some View {
		content.font(.footnote)
	}
}

extension View {
	func pagePresentationIfPossible() -> some View {		
		if #available(iOS 18.0, *) {
			return self
				.presentationSizing(
					.page
				)
		} else {
			return self
		}
	}
}

extension View {
	@ViewBuilder
	func deviceAppropriateModalPresentation<Content: View>(isPresented: Binding<Bool>, attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds), arrowEdge: Edge? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.popover(isPresented: isPresented, attachmentAnchor: attachmentAnchor, arrowEdge: arrowEdge, content: content)
		} else {
			self.sheet(isPresented: isPresented, content: content)
		}
	}
}

struct SceneSelection: View {
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.colorScheme) var colorScheme
	
	@State var tabnavPresented: Bool = false
	@State var tabPresented: Bool = false
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
	
	@AppStorage(.enableFunkyInheritedFont, store: .settings) var enableFunkyInheritedFont: Bool = false
	@AppStorage(.enableExternalScenes, store: .settings) var enableExternalScenes: Bool = false
	
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
					CellPaddedButton("Navigation View") {
						navPresented.toggle()
					}
					.fullScreenCover(isPresented: $navPresented, content: {
						NavDemoView(title: nil, demoContent: DemoContent()) {
							navPresented.toggle()
						}
					})
					CellPaddedButton("Navigation View (Sheet)") {
						viewSheetPresented.toggle()
					}
					.sheet(isPresented: $viewSheetPresented, content: {
						NavDemoView(title: nil, demoContent: DemoContent()) {
							viewSheetPresented.toggle()
						}
						.pagePresentationIfPossible()
					})
					CellPaddedButton("View") {
						viewPresented.toggle()
					}
					.fullScreenCover(isPresented: $viewPresented, content: {
						ViewDemoView(demoContent: DemoContent()) {
							viewPresented.toggle()
						}
					})
					if #available(iOS 17, *) {
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
					}
				} header: {
					LNHeaderFooterView("Standard Scenes")
				} footer: {
					LNHeaderFooterView("Presents a standard test scene with a popup bar.")
				}
				Section {
					if #available(iOS 18.0, *) {
						CellPaddedButton("Music") {
							musicSheetPresented.toggle()
						}
						.fullScreenCover(isPresented: $musicSheetPresented, content: {
							MusicView {
								musicSheetPresented.toggle()
							}
						})
					} else {
						CellPaddedButton("Music") {
						}.disabled(true)
					}
				} header: {
					LNHeaderFooterView("Demo Apps")
				} footer: {
					LNHeaderFooterView("Presents a rudimentary recreation of a music app.")
				}
				Section {
					CellPaddedButton("Maps") {
						mapSheetPresented.toggle()
					}
					.fullScreenCover(isPresented: $mapSheetPresented, content: {
						CustomBarMapView {
							mapSheetPresented.toggle()
						}
					})
				} header: {
					LNHeaderFooterView("Custom Popup Bar")
				} footer: {
					LNHeaderFooterView("Presents a scene with a custom popup bar view and a UIKit popup content controller")
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
						LNHeaderFooterView("External Libraries—Gestures")
					} footer: {
						LNHeaderFooterView("Presents a popup content view with [CompactSlider](https://github.com/buh/CompactSlider) elements, to test gesture handling in the library.")
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
					.deviceAppropriateModalPresentation(isPresented: $settingsPresented, content: {
						SettingsNavView()
							.frame(minWidth: verticalSizeClass == .regular && horizontalSizeClass == .regular ? 375 : nil, minHeight: verticalSizeClass == .regular && horizontalSizeClass == .regular ? 600 : nil)
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
//		.font(font)
		.font(enableFunkyInheritedFont ? font : nil)
	}
}

struct SceneSelection_Previews: PreviewProvider {
	static var previews: some View {
		SceneSelection()
	}
}
