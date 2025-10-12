//
//  MusicView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

@MainActor
var counter: Int = 1

@MainActor
func nextGenre() -> Int {
	let rv = counter;
	counter += 1
	if counter == 30 {
		counter = 1
	}
	return rv
}

@MainActor
struct RandomTitleSong : Equatable, Identifiable {
	var id: Int
	let imageName: String = "genre\(nextGenre())"
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
}

@MainActor
fileprivate let songs: [[RandomTitleSong]] = {
	var songs: [[RandomTitleSong]] = []
	for jdx in 0..<4 {
		songs.append([])
		for idx in 1..<31 {
			songs[jdx].append(RandomTitleSong(id: idx))
		}
	}
	return songs
}()

struct RandomTitlesListView : View {
	@Environment(\.presentationMode) var presentationMode
	private let title: String
	private let idx: Int
	
	@Binding var isPopupPresented: Bool
	private let onSongSelect: (RandomTitleSong) -> Void
	private let onDismiss: () -> Void
	
	init(_ title: String, idx: Int, _ isPopupPresented: Binding<Bool>, onDismiss: @escaping () -> Void, onSongSelect: @escaping (RandomTitleSong) -> Void) {
		self.title = title
		self.idx = idx
		self._isPopupPresented = isPopupPresented
		self.onDismiss = onDismiss
		self.onSongSelect = onSongSelect
	}
	
	var body: some View {
		MaterialNavigationStack {
			List(songs[idx]) { song in
				Button {
					onSongSelect(song)
				} label: {
					HStack(spacing: 20) {
						Image(song.imageName)
							.resizable()
							.frame(width: 48, height: 48)
							.cornerRadius(8)
						
						VStack(alignment: .leading) {
							LNPopupText(song.title)
								.font(.headline)
								.lineLimit(1)
								.truncationMode(.tail)
							LNPopupText(song.subtitle)
								.font(.subheadline)
								.lineLimit(1)
								.truncationMode(.tail)
						}
					}
				}
			}
			.listStyle(PlainListStyle())
			.navigationTitle(NSLocalizedString(title, comment: ""))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						isPopupPresented = false
					} label: {
						Image(systemName: isPopupPresented ? "rectangle.bottomthird.inset.fill" : "rectangle")
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					ToolbarCloseButton {
						onDismiss()
					}
				}
			}
		}
	}
}

struct MinimizeIfPossibleModifier: ViewModifier {
	func body(content: Content) -> some View {
#if compiler(>=6.2)
		if #available(iOS 26, *) {
			content.tabBarMinimizeBehavior(.onScrollDown)
		} else {
			content
		}
#else
		content
#endif
	}
}

@available(iOS 18.0, *)
struct MusicView: View {
	@State var isPopupBarPresented: Bool = false
	@State var isPopupOpen: Bool = false
	
	@State var currentSong: RandomTitleSong?
	
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		MaterialTabView {
			Tab(NSLocalizedString("Home", comment: ""), systemImage: "music.note.house.fill") {
				RandomTitlesListView("Home", idx: 0, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(NSLocalizedString("New", comment: ""), systemImage: "square.grid.2x2.fill") {
				RandomTitlesListView("New", idx: 1, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(NSLocalizedString("Library", comment: ""), systemImage: ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 ? "music.note.square.stack.fill" : "square.stack.fill") {
				RandomTitlesListView("Library", idx: 2, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(role: .search) {
				DumbSearchView()
			}
		}
		.modifier(MinimizeIfPossibleModifier())
		.accentColor(.pink)
		.onChange(of: currentSong) { newValue in
			isPopupBarPresented = newValue != nil
		}
		.onChange(of: isPopupBarPresented) { newValue in
			if newValue == false {
				currentSong = nil
			}
		}
		.popup(isBarPresented: $isPopupBarPresented, isPopupOpen: $isPopupOpen) {
			if let currentSong = currentSong {
				PlayerView(song: currentSong)
			}
		}
		.popupBarShineEnabled(true)
		.popupBarProgressViewStyle(.bottom)
		.font(nil)
	}
}

@available(iOS 18.0, *)
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MusicView(onDismiss: {})
	}
}
