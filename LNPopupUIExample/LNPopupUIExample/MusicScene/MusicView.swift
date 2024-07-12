//
//  MusicView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 8/6/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct RandomTitleSong : Equatable, Identifiable {
	var id: Int
	var imageName: String {
		"genre\(id)"
	}
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
}

fileprivate let songs: [RandomTitleSong] = {
	var songs: [RandomTitleSong] = []
	for idx in 1..<31 {
		songs.append(RandomTitleSong(id: idx))
	}
	return songs
}()

struct RandomTitlesListView : View {
	@Environment(\.presentationMode) var presentationMode
	private let title: String
	
	@Binding var isPopupPresented: Bool
	private let onSongSelect: (RandomTitleSong) -> Void
	private let onDismiss: () -> Void
	
	init(_ title: String, _ isPopupPresented: Binding<Bool>, onDismiss: @escaping () -> Void, onSongSelect: @escaping (RandomTitleSong) -> Void) {
		self.title = title
		self._isPopupPresented = isPopupPresented
		self.onDismiss = onDismiss
		self.onSongSelect = onSongSelect
	}
	
	var body: some View {
		MaterialNavigationStack {
			List(songs) { song in
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
			RandomTitlesListView("Music", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Music")
				Image(systemName: "play.circle.fill")
			}
			RandomTitlesListView("Artists", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Artists")
				Image(systemName: "music.mic")
			}
			RandomTitlesListView("Composers", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Composers")
				Image(systemName: "music.quarternote.3")
			}
			RandomTitlesListView("Recents", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Recents")
				Image(systemName: "clock.fill")
			}
		}
		.accentColor(.pink)
		.onChange(of: currentSong) { newValue in
			isPopupBarPresented = newValue != nil
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

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MusicView(onDismiss: {})
	}
}
