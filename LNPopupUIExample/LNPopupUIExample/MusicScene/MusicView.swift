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
	var id: String
	let imageName: String = "genre\(nextGenre())"
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
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
}

struct RandomTitlesListView : View {
	@Environment(\.presentationMode) var presentationMode
	private let title: String
	private let idx: Int
	
	private let onSongSelect: (RandomTitleSong) -> Void
	private let onDismiss: () -> Void
	
	init(_ title: String, idx: Int, onDismiss: @escaping () -> Void, onSongSelect: @escaping (RandomTitleSong) -> Void) {
		self.title = title
		self.idx = idx
		self.onDismiss = onDismiss
		self.onSongSelect = onSongSelect
	}
	
	var body: some View {
		MaterialNavigationStack {
			List(songs[idx]) { song in
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
							LNPopupText(song.subtitle)
								.font(.footnote)
								.lineLimit(1)
								.truncationMode(.tail)
						}
					}
				}
				.noVerticalListRowInsetsIfPossible()
			}
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
	@State var isPopupOpen: Bool = false
	
	@State var currentSong: RandomTitleSong?
	
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		MaterialTabView {
			Tab(NSLocalizedString("Home", comment: ""), systemImage: "music.note.house.fill") {
				RandomTitlesListView("Home", idx: 0, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(NSLocalizedString("New", comment: ""), systemImage: "square.grid.2x2.fill") {
				RandomTitlesListView("New", idx: 1, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(NSLocalizedString("Library", comment: ""), systemImage: ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 ? "music.note.square.stack.fill" : "square.stack.fill") {
				RandomTitlesListView("Library", idx: 2, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab(role: .search) {
				DumbSearchView()
			}
		}
		.modifier(MinimizeIfPossibleModifier())
		.accentColor(.pink)
		.popup(isBarPresented: Binding.constant(true), isPopupOpen: $isPopupOpen) {
			PlayerView(song: currentSong)
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
