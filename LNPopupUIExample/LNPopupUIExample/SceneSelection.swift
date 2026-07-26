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
		if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
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
	@State var musicSheetPresented: Bool = false
	@State var mapSheetPresented: Bool = false
	@State var splitViewPresented: Bool = false
	@State var splitViewGlobalPresented: Bool = false
	@State var dynamicBarContentPresented: Bool = false
	
	@State var settingsPresented: Bool = false
	@State private var item: ActivityItem? = nil
	
	@AppStorage(.enableFunkyInheritedFont, store: .settings) var enableFunkyInheritedFont: Bool = false
	
	let font = Font.custom("Chalkduster", size: 15, relativeTo: .subheadline)
//	let font = Font.custom("Avenir Next", fixedSize: 15).weight(.heavy).italic()
//	let font = Font.custom("Zapfino", size: 15).italic().weight(.heavy).width(.condensed)
//	let font = Font.system(size: 15, weight: .regular)
//	let font = Font.system(size: 15, weight: .regular).monospacedDigit()
//	let font = Font.system(size: 15, weight: .black).monospaced().lowercaseSmallCaps()
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Button("Tab View + Navigation View") {
						tabnavPresented.toggle()
					}
					.fullScreenCover(isPresented: $tabnavPresented, content: {
						TabNavView(demoContent: DemoContent()) {
							tabnavPresented.toggle()
						}
					})
					Button("Tab View") {
						tabPresented.toggle()
					}
					.fullScreenCover(isPresented: $tabPresented, content: {
						TabDemoView(demoContent: DemoContent()) {
							tabPresented.toggle()
						}
					})
					Button("Navigation View") {
						navPresented.toggle()
					}
					.fullScreenCover(isPresented: $navPresented, content: {
						NavDemoView(title: nil, demoContent: DemoContent()) {
							navPresented.toggle()
						}
					})
					Button("Navigation View (Sheet)") {
						viewSheetPresented.toggle()
					}
					.sheet(isPresented: $viewSheetPresented, content: {
						NavDemoView(title: nil, demoContent: DemoContent()) {
							viewSheetPresented.toggle()
						}
						.pagePresentationIfPossible()
					})
					Button("View") {
						viewPresented.toggle()
					}
					.fullScreenCover(isPresented: $viewPresented, content: {
						ViewDemoView(demoContent: DemoContent()) {
							viewPresented.toggle()
						}
					})
					if #available(iOS 17, *) {
						Group {
							Button("Split View (All)") {
								splitViewPresented.toggle()
							}.fullScreenCover(isPresented: $splitViewPresented) {
								SplitDemoView(isGlobal: false) {
									splitViewPresented.toggle()
								}
							}
							Button("Split View (Global)") {
								splitViewGlobalPresented.toggle()
							}
							.fullScreenCover(isPresented: $splitViewGlobalPresented) {
								SplitDemoView(isGlobal: true) {
									splitViewGlobalPresented.toggle()
								}
							}
						}
					}
				} header: {
					LNPopupText("Standard Scenes")
				} footer: {
					LNPopupText("Presents a standard test scene with a popup bar.")
				}
				if #available(iOS 17, *) {
					Section {
						Button("Dynamic Bar Content") {
							dynamicBarContentPresented.toggle()
						}
						.fullScreenCover(isPresented: $dynamicBarContentPresented) {
							DynamicBarContent {
								dynamicBarContentPresented.toggle()
							}
						}
					} header: {
						LNPopupText("Dynamic Bar Content")
					} footer: {
						LNPopupText("Presents a scene where the popup bar content is dynamically updated, depending on available space")
					}
				}
				Section {
					if #available(iOS 18.0, *) {
						Button("Music") {
							musicSheetPresented.toggle()
						}
						.fullScreenCover(isPresented: $musicSheetPresented, content: {
							MusicView {
								musicSheetPresented.toggle()
							}
						})
					} else {
						Button("Music") {}
							.disabled(true)
					}
				} header: {
					LNPopupText("Demo Apps")
				} footer: {
					LNPopupText("Presents a rudimentary recreation of a music app.")
				}
				Section {
					Button("Maps") {
						mapSheetPresented.toggle()
					}
					.fullScreenCover(isPresented: $mapSheetPresented, content: {
						CustomBarMapView {
							mapSheetPresented.toggle()
						}
					})
				} header: {
					LNPopupText("Custom Popup Bar")
				} footer: {
					LNPopupText("Presents a scene with a custom popup bar view and a UIKit popup content controller")
				}
			}
			.foregroundStyle(.primary)
			.listStyle(.insetGrouped)
			.navigationBarTitle(NSLocalizedString("LNPopupUI", comment: ""))
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						settingsPresented.toggle()
					} label: {
#if targetEnvironment(macCatalyst)
						Label("Settings", systemImage: "gearshape")
							.labelStyle(.iconOnly)
#else
						Label("Settings", image: "gears")
							.labelStyle(.iconOnly)
#endif
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
#if targetEnvironment(macCatalyst)
		.popupCloseButtonPositioning(.leading)
		.popupCloseButtonStyle(.glass)
#else
		.popupCloseButtonStyle(.grabber)
		.popupBarStyle(.floating)
		.popupBarShineEnabled(ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 27)
#endif
		.popupBarInheritsBottomBarMetrics(false)
		.popupBarContextMenu {
			Link(destination: URL(string: "https://github.com/LeoNatan/LNPopupUI")!) {
				LNPopupText("Visit GitHub Page")
				Image(systemName: "safari")
			}
			Link(destination: URL(string: "https://github.com/LeoNatan/LNPopupUI/issues/new/choose")!) {
				LNPopupText("Report an Issue…")
				Image(systemName: "ant.fill")
			}
			Divider()
			Button {
				item = ActivityItem(
					items: URL(string: "https://github.com/LeoNatan/LNPopupUI")!
				)
			} label: {
				LNPopupText("Share…")
				Image(systemName: "square.and.arrow.up")
			}
		}
		.activitySheet($item)
		.font(enableFunkyInheritedFont ? font : nil)
	}
}

#Preview {
	SceneSelection()
}
