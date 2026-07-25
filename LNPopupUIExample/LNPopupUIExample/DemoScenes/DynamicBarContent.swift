//
//  DynamicBarContent.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 25/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

import SwiftUI
import LNPopupUI
import AVKit
import ActivityView

@available(iOS 17.0, *)
struct DynamicBarContent: View {
	let onDismiss: () -> Void
	
	enum PopupBarButtonsStyle: Int, Equatable {
		case minimal
		case expandedMinimal
		case large3
		case large2
		case large1
		
		var isLarge: Bool {
			return [ .minimal, .expandedMinimal ].contains(self) == false
		}
		
		@ViewBuilder
		func ifAtLeast(_ style: PopupBarButtonsStyle, @ViewBuilder perform: () -> some View) -> some View {
			if self.rawValue >= style.rawValue {
				perform()
			}
		}
	}
	
	enum PopupBarButtonsHeight: Equatable {
		case standard
		case allowLarge
	}
	
	@Environment(\.font) var inheritedFont
	@State var isBarPresented: Bool = true
	@State var isPopupOpen: Bool = false
	
	@State private var item: ActivityItem? = nil
	
	@State var barButtonsStyle: PopupBarButtonsStyle = .large1
	@State var barButtonsHeight: PopupBarButtonsHeight = .allowLarge
	
	@ViewBuilder
	func prevStopNext(allowPrev: Bool, allowLargeSizes: Bool) -> some View {
		if allowPrev {
			let prev = Button {
				print("Prev")
			} label: {
				Image(systemName: "backward.fill")
			}
			
			if allowLargeSizes {
				prev
					.font(.title3)
					.imageScale(.medium)
			} else {
				prev
			}
		}
		
		let playPause = Button {
			print("Play/pause")
		} label: {
			Image(systemName: "stop.fill")
		}
		
		if allowLargeSizes {
			playPause
				.font(.title)
				.imageScale(.large)
		} else {
			playPause
		}
		
		let next = Button {
			print("Next")
		} label: {
			Image(systemName: "forward.fill")
		}
		
		if allowLargeSizes {
			next
				.font(.title3)
				.imageScale(.medium)
		} else {
			next
		}
	}
	
	var body: some View {
		NavigationSplitView(columnVisibility: Binding.constant(.all), preferredCompactColumn: Binding.constant(.detail)) {
			ContentUnavailableView {
				Text("Sidebar")
			}
			.ignoresSafeArea()
		} detail: {
			ContentUnavailableView {
				Text("Content")
			}
			.ignoresSafeArea()
			.popup(isBarPresented: $isBarPresented, isPopupOpen: $isPopupOpen) {
				ContentUnavailableView {
					Text("Popup Content")
				}
				.ignoresSafeArea()
				.popupItem {
					PopupItem(id: "intro", image: Image("AppIconPopupBar"), progress: .random(in: 0.2..<0.4)) {
						HStack {
							Text(NSLocalizedString("Welcome to ", comment: "")) + Text(NSLocalizedString("LNPopupUI", comment: "")).fontWeight(.heavy) + Text("!")
						}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).font(inheritedFont ?? .body)
					} leadingButtons: {
						if barButtonsStyle.isLarge {
							ToolbarItemGroup(placement: .popupBar) {
								HStack(alignment: .center, spacing: 12) {
									barButtonsStyle.ifAtLeast(.large2) {
										Button {
											print("Shuffle")
										} label: {
											Image(systemName: "shuffle")
										}
										.foregroundStyle(Color(uiColor: .secondaryLabel))
										.imageScale(.small)
									}
									
									prevStopNext(allowPrev: true, allowLargeSizes: true)
									
									barButtonsStyle.ifAtLeast(.large2) {
										Button {
											print("Repeat")
										} label: {
											Image(systemName: "repeat")
										}
										.foregroundStyle(Color(uiColor: .secondaryLabel))
										.imageScale(.small)
									}
								}
								.buttonStyle(.borderless)
							}
						}
					} trailingButtons: {
						ToolbarItemGroup(placement: .popupBar) {
							Group {
								if barButtonsStyle.isLarge {
									Group {
										Menu {
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
										} label: {
											Image(systemName: "ellipsis")
										}

										barButtonsStyle.ifAtLeast(.large1) {
											AirPlayView()
											
											Button {
												print("Volume")
											} label: {
												Image(systemName: "speaker.wave.2.fill")
											}
										}
									}
									.font(.title3)
									.imageScale(.medium)
									.buttonStyle(.borderless)
								} else {
									prevStopNext(allowPrev: barButtonsStyle == .expandedMinimal, allowLargeSizes: barButtonsHeight == .allowLarge)
									
								}
							}
						}
					}
				}
			}
			.popupCloseButtonPositioning(.leading)
			.popupBarCustomizer { popupBar in
				popupBar.tintColor = .label
			}
			.popupBarProgressViewStyle(.bottom)
			.activitySheet($item)
		.navigationSplitViewStyle(.balanced)
		.navigationSplitViewColumnWidth(min: 270, ideal: 375, max: 450)
	}
}

struct AirPlayView: UIViewRepresentable {
	func makeUIView(context: Context) -> UIView {
		
		let routePickerView = AVRoutePickerView()		
		return routePickerView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
	}
}
