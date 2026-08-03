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

@available(iOS 26.0, *)
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
	
	@State var count = 0
	
	let isCatalyst = ProcessInfo.processInfo.isMacCatalystApp || ProcessInfo.processInfo.isiOSAppOnMac
	
	@State var showPicker: Bool = false
	@AppStorage("useTabViewInDynamic") var useTabView = false
	
	var body: some View {
		ZStack(alignment: .top) {
			if useTabView {
				TabView {
					ForEach(1..<5) { idx in
						let title = "Content \(idx)"
						Tab(title, systemImage: "\(idx).square") {
							NavigationStack {
								
								paneContent(title: title, addToolbar: true)
							}
							.toolbar(isCatalyst ? .hidden : .automatic, for: .tabBar)
						}
					}
				}
				.tabViewSidebarFooter {
					paneContent(title: "Sidebar")
				}
				.tabViewStyle(.sidebarAdaptable)
			} else {
				NavigationSplitView(columnVisibility: Binding.constant(.all), preferredCompactColumn: Binding.constant(.detail)) {
					paneContent(title: "Sidebar")
				} detail: {
					NavigationStack {
						paneContent(title: "Content", addToolbar: true)
					}
				}
				.navigationSplitViewStyle(.balanced)
				.navigationSplitViewColumnWidth(min: 270, ideal: 375, max: 450)
			}
		}
		.tint(.blue)
		.popup(isBarPresented: $isBarPresented, isPopupOpen: $isPopupOpen) {
			paneContent(title: "Popup Content")
				.popupItem {
					dynamicBarContentPopupItem()
				}
		}
		.popupCloseButtonPositioning(.leading)
		.popupBarCustomizer { popupBar in
			popupBar.tintColor = .label
		}
		.popupBarProgressViewStyle(.bottom)
		.activitySheet($item)
		.onPopupBarGeometryChange(for: PopupBarButtonsStyle.self) { layoutProxy in
			switch layoutProxy.horizontalSizeClass {
			case .regular:
				if layoutProxy.userInterfaceIdiom == .phone {
					return .expandedMinimal
				}
				
#if targetEnvironment(macCatalyst)
				let lowerBound = 500.0
				let upperBound = 600.0
#else
				let lowerBound = 580.0
				let upperBound = 650.0
#endif
				
				if layoutProxy.effectiveBarContentSize.width < lowerBound {
					return .large3
				} else if layoutProxy.effectiveBarContentSize.width < upperBound {
					return .large2
				} else {
					return .large1
				}
			default:
				return .minimal
			}
		} action: { newStyle in
			barButtonsStyle = newStyle
		}
		.onPopupBarGeometryChange(for: PopupBarButtonsHeight.self) { layoutProxy in
			if layoutProxy.userInterfaceIdiom == .mac {
				return .allowLarge
			}
			
			switch layoutProxy.effectiveBarStyle {
			case .floating:
				return .allowLarge
			default:
				return .standard
			}
		} action: { oldHeight, newHeight in
			barButtonsHeight = newHeight
		}
	}
	
	func dynamicBarContentPopupItem() -> PopupItem<String> {
		PopupItem(id: "intro", image: Image("AppIconPopupBar"), progress: .random(in: 0.2..<0.4)) {
			VStack {
				Text("\(Text(NSLocalizedString("Welcome to", comment: ""))) \(Text(NSLocalizedString("LNPopupUI", comment: "")).fontWeight(.heavy))\(Text("!"))")
			}.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading).font(inheritedFont ?? .body)
		} leadingButtons: {
			ToolbarItemGroup(placement: .popupBar) {
				if barButtonsStyle.isLarge {
					Group {
						HStack(spacing: 12) {
							barButtonsStyle.ifAtLeast(.large1) {
								Button {
									print("Shuffle")
								} label: {
									Image(systemName: "shuffle")
								}
								.foregroundStyle(Color(uiColor: .secondaryLabel))
							}
							
							prevStopNext(allowPrev: true, allowLargeSizes: barButtonsHeight == .allowLarge)
							
							barButtonsStyle.ifAtLeast(.large1) {
								Button {
									print("Repeat")
								} label: {
									Image(systemName: "repeat")
								}
								.foregroundStyle(Color(uiColor: .secondaryLabel))
							}
						}
						.buttonStyle(.borderless)
						.imageScale(.small)
					}
				}
			}
		} trailingButtons: {
			ToolbarItemGroup(placement: .popupBar) {
				if barButtonsStyle.isLarge {
					Group {
						promoMenu()
						
						barButtonsStyle.ifAtLeast(.large2) {
							AirPlayView()
							
							Button {
								print("Volume")
							} label: {
								Image(systemName: "speaker.wave.2.fill")
							}
						}
					}
					.medium(barButtonsHeight == .allowLarge)
					.buttonStyle(.borderless)
				} else {
					prevStopNext(allowPrev: barButtonsStyle == .expandedMinimal, allowLargeSizes: barButtonsHeight == .allowLarge)
				}
			}
		}
	}
	
	@ViewBuilder
	func paneContent(title: String, addToolbar: Bool = false) -> some View {
		ContentUnavailableView {
			VStack {
				LNPopupText("\(title): \(count)")
					.foregroundStyle(.secondary)
				HStack(spacing: 20) {
					Button {
						count -= 1
					} label: {
						Text("-")
							.frame(width: 20, height: 15)
					}
					Button {
						count += 1
					} label: {
						Text("+")
							.frame(width: 20, height: 15)
					}
				}
				.buttonStyle(.bordered)
				.buttonBorderShape(.roundedRectangle)
			}
		}
		.toolbar {
			if addToolbar {
				if showPicker {
					ToolbarItem(id: "chooser", placement: .topBarTrailing) {
						Picker(selection: $useTabView) {
							Text("TabView").tag(true)
							Text("SplitView").tag(false)
						} label: {
							EmptyView()
						}
						.pickerStyle(.segmented)
						.controlSize(.mini)
						.frame(height: 20)
					}
#if !targetEnvironment(macCatalyst)
					.sharedBackgroundVisibility(.hidden)
#endif
					ToolbarSpacer(.fixed, placement: .topBarTrailing)
					ToolbarItem(id: "open-close", placement: .topBarTrailing) {
						Button {
							showPicker = false
						} label: {
							Label {} icon: {
								Image(systemName: "chevron.forward")
							}
						}
						.tint(nil)
					}
				} else {
					ToolbarItem(id: "open-close", placement: .topBarTrailing) {
						Button {
							showPicker = true
						} label: {
							Label {} icon: {
								Image(systemName: "ellipsis")
							}
						}
						.tint(nil)
					}
				}
#if !targetEnvironment(macCatalyst)
				ToolbarItem(id: "dismiss", placement: .confirmationAction) {
					ToolbarCloseButton {
						onDismiss()
					}
				}
#endif
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea(.all, edges: .vertical)
	}
	
	@ViewBuilder
	func promoMenu() -> some View {
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
	}
	
	@ViewBuilder
	func prevStopNext(allowPrev: Bool, allowLargeSizes: Bool) -> some View {
		if allowPrev {
			Button {
				print("Prev")
			} label: {
				Image(systemName: "backward.fill")
			}.medium(allowLargeSizes)
		}
		
		Button {
			print("Play/pause")
		} label: {
			Image(systemName: "stop.fill")
		}.large(allowLargeSizes)
		
		Button {
			print("Next")
		} label: {
			Image(systemName: "forward.fill")
		}.medium(allowLargeSizes)
	}
}

extension View {
	@ViewBuilder
	func large(_ allow: Bool) -> some View {
		if allow {
			self
				.font(.title)
				.imageScale(.large)
		} else {
			self
		}
	}
	
	@ViewBuilder
	func medium(_ allow: Bool) -> some View {
		if allow {
			self
				.font(.title3)
				.imageScale(.medium)
		} else {
			self
		}
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
