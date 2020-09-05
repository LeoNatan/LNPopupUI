//
//  MusicView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import LoremIpsum
import LNPopupUI

struct RandomTitleSong : Identifiable {
	var id: Int
	var imageName: String {
		"genre\(id)"
	}
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
}

fileprivate var songs: [RandomTitleSong] = {
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
		NavigationView {
			List(songs) { song in
				Button(action: {
					onSongSelect(song)
				}) {
					HStack {
						Image(song.imageName)
							.resizable()
							.frame(width: 48, height: 48)
							.cornerRadius(8)
							.padding(2.5)
						
						VStack(alignment: .leading) {
							Text(song.title)
								.font(.headline)
								.lineLimit(1)
							Text(song.subtitle)
								.font(.subheadline)
								.lineLimit(1)
						}
						.multilineTextAlignment(.leading)
					}
				}
			}
			.listStyle(PlainListStyle())
			.navigationBarTitle(title)
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarItems(leading: Image(systemName: isPopupPresented ? "rectangle.bottomthird.inset.fill" : "rectangle"), trailing: Button("Gallery") {
				onDismiss()
			})
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct MusicView: View {
	@State var isPopupPresented: Bool = false
	@State var isPopupOpen: Bool = false
	
	@State var currentSong: RandomTitleSong? {
		didSet {
			DispatchQueue.main.async {
				isPopupPresented = true
			}
		}
	}
	
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		TabView {
			RandomTitlesListView("Music", $isPopupPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Music")
				Image(systemName: "play.circle.fill")
			}
			RandomTitlesListView("Artists", $isPopupPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Artists")
				Image(systemName: "music.mic")
			}
			RandomTitlesListView("Composers", $isPopupPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Composers")
				Image(systemName: "music.quarternote.3")
			}
			RandomTitlesListView("Recents", $isPopupPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Recents")
				Image(systemName: "clock.fill")
			}
		}
		.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
			if let currentSong = currentSong {
				PlayerView(song: currentSong)
			}
		}
		//		.popupInteractionStyle(.drag)
		.popupBarStyle(.prominent)
		.popupBarProgressViewStyle(.top)
		.popupBarMarqueeScrollEnabled(true)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MusicView(onDismiss: {})
	}
}
