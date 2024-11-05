//
//  MusicView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-08-06.
//  Copyright © 2020-2024 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct RandomTitleSong : Equatable, Identifiable {
	var id: Int
	let imageName: String = "genre\(Int.random(in: 1...30))"
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
}

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
							Text(song.title)
								.font(.headline)
								.lineLimit(1)
								.truncationMode(.tail)
							Text(song.subtitle)
								.font(.subheadline)
								.lineLimit(1)
								.truncationMode(.tail)
						}
					}
				}
			}
			.listStyle(PlainListStyle())
			.navigationBarTitle(title)
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
					Button("Gallery") {
						onDismiss()
					}
				}
			}
		}
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
			Tab("Music", systemImage: "play.circle") {
				RandomTitlesListView("Music", idx: 0, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab("Artists", systemImage: "music.mic") {
				RandomTitlesListView("Artists", idx: 1, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab("Composers", systemImage: "music.quarternote.3") {
				RandomTitlesListView("Composers", idx: 2, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
			Tab("Recents", systemImage: "clock") {
				RandomTitlesListView("Recents", idx: 3, $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
					currentSong = song
				})
			}
		}
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
		.popupBarProgressViewStyle(.top)
		.font(nil)
	}
}

@available(iOS 18.0, *)
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MusicView(onDismiss: {})
	}
}
