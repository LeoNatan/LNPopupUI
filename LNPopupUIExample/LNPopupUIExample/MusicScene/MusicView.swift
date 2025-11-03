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
struct RandomTitleSong : Hashable, Identifiable {
	static let notPLayingId = "not_playing"
	
	var id: String
	var imageName: String = "genre\(nextGenre())"
	var title: String = LoremIpsum.title
	var albumName: String? = LoremIpsum.words(withNumber: 5).capitalized
	
	static let notPlaying: RandomTitleSong = {
		var rv = RandomTitleSong(id: "notPlaying")
		rv.title = NSLocalizedString("Not Playing", comment: "")
		rv.imageName = "NotPlaying"
		rv.albumName = nil
		return rv
	}()
	
	var isNotPlaying: Bool {
		id == Self.notPLayingId
	}
}

@MainActor
fileprivate let songs: [[RandomTitleSong]] = {
	var songs: [[RandomTitleSong]] = []
	for jdx in 0..<4 {
		songs.append([])
		for idx in 1...Int.random(in: 25...45) {
			songs[jdx].append(RandomTitleSong(id: "\(jdx)-\(idx)"))
		}
	}
	return songs
}()

extension View {
	@ViewBuilder
	func noVerticalListRowInsetsIfPossible() -> some View {
		if #available(iOS 26.0, *) {
			listRowInsets(.vertical, 4.0)
		} else {
			self
		}
	}
	
	@ViewBuilder
	func selectedSongBackground(_ selected: Bool) -> some View {
		if selected {
			listRowBackground(Color.accent.opacity(0.2))
		} else {
			self
		}
	}
}

struct RandomTitlesListView : View {
	@Environment(\.presentationMode) var presentationMode
	private let title: String
	private let currentSong: RandomTitleSong
	private let songs: [RandomTitleSong]
	
	private let onSongSelect: (RandomTitleSong) -> Void
	private let onDismiss: () -> Void
	
	init(_ title: String, currentSong: RandomTitleSong, songs: [RandomTitleSong], onDismiss: @escaping () -> Void, onSongSelect: @escaping (RandomTitleSong) -> Void) {
		self.title = title
		self.currentSong = currentSong
		self.songs = songs
		self.onDismiss = onDismiss
		self.onSongSelect = onSongSelect
	}
	
	var body: some View {
		MaterialNavigationStack {
			List(songs) { song in
				Button {
					onSongSelect(song)
				} label: {
					HStack(spacing: 10) {
						Image(song.imageName)
							.resizable()
							.frame(width: 48, height: 48)
							.cornerRadius(8)
						VStack(alignment: .leading, spacing: 2) {
							LNPopupText(song.title)
								.font(.body)
								.lineLimit(1)
								.truncationMode(.tail)
							if let albumName = song.albumName {
								LNPopupText(albumName)
									.font(.footnote)
									.lineLimit(1)
									.truncationMode(.tail)
							}
						}
					}
				}
				.selectedSongBackground(song.id == currentSong.id)
				.noVerticalListRowInsetsIfPossible()
			}
			.animation(.spring, value: currentSong)
			.listStyle(PlainListStyle())
			.navigationTitle(NSLocalizedString(title, comment: ""))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
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
		if #available(iOS 26, *) {
			content.tabBarMinimizeBehavior(.onScrollDown)
		} else {
			content
		}
	}
}

@available(iOS 18.0, *)
struct MusicView: View {
	@State var isPopupOpen: Bool = false
	
	@State var currentPlaylist: [RandomTitleSong]?
	@State var currentSong: RandomTitleSong = .notPlaying
	
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	let titles = ["Home", "New", "Library"]
	let imageNames = ["music.note.house.fill", "square.grid.2x2.fill", ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 ? "music.note.square.stack.fill" : "square.stack.fill"]
	
	var body: some View {
		MaterialTabView {
			ForEach(0..<3) { tabIdx in
				let title = NSLocalizedString(titles[tabIdx], comment: "")
				Tab(NSLocalizedString(title, comment: ""), systemImage: imageNames[tabIdx]) {
					RandomTitlesListView(title, currentSong: currentSong, songs: songs[tabIdx], onDismiss:onDismiss, onSongSelect: { song in
						currentPlaylist = songs[tabIdx]
						currentSong = song
					})
				}
			}
			Tab(role: .search) {
				DumbSearchView()
			}
		}
		.modifier(MinimizeIfPossibleModifier())
		.accentColor(.pink)
		.popup(isBarPresented: Binding.constant(true), isPopupOpen: $isPopupOpen) {
			PlayerView(song: $currentSong, currentPlaylist: currentPlaylist)
		}
		.popupBarShineEnabled(true)
		.popupBarProgressViewStyle(.bottom)
		.font(nil)
	}
}

@available(iOS 18.0, *)
#Preview {
	MusicView(onDismiss: {})
}
