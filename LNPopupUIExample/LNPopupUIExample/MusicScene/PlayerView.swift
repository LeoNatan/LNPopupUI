//
//  PlayerView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LNPopupUI
import LNPopupController
import LoremIpsum
import Combine
import SwiftUIIntrospect

@available(iOS 17.0, *)
struct PlaybackState {
	var isPlaying: Bool = true
	
	var progress: Float = 0.0
	var isUserScrubbing: Bool = false
	var volume: Float = 0.5
	
	var onPrevSong: (() -> Void)?
	var onNextSong: (() -> Void)?
}

@available(iOS 17.0, *)
struct PlayerView: View {
	@Binding var song: RandomTitleSong
	let currentPlaylist: [RandomTitleSong]?
	
	@State var playbackState = PlaybackState()
	
	@Environment(\.popupBarPlacement) var popupBarPlacement
	
	@ViewBuilder
	func albumArtImage(with geometry: GeometryProxy) -> some View {
		Image(song.imageName)
			.resizable()
			.clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
			.shadow(color: song.isNotPlaying ? .clear : Color(.sRGBLinear, white: 0, opacity: 0.33), radius: 10)
			.aspectRatio(1.0, contentMode: .fit)
			.padding([.leading, .trailing], 10)
			.padding([.top], geometry.size.height * 60 / 896.0)
	}
	
	@ViewBuilder
	func titles(with geometry: GeometryProxy) -> some View {
		HStack {
			VStack(alignment: .leading) {
				Text(song.title)
					.font(.system(size: 20, weight: .bold))
				Text(song.albumName ?? "")
					.font(.system(size: 20, weight: .regular))
			}
			.lineLimit(1)
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   alignment: .topLeading)
			Button(action: {}, label: {
				Image(systemName: "ellipsis.circle")
					.font(.title)
			})
		}
	}
	
	@ViewBuilder
	func slider(with geometry: GeometryProxy) -> some View {
		let slider = Slider(value: $playbackState.progress)
			.padding([.bottom], geometry.size.height * 30.0 / 896.0)
		
		if #available(iOS 26.0, *) {
			slider.sliderThumbVisibility(.hidden)
		} else {
			slider
		}
	}
	
	@ViewBuilder
	func playbackControls(with geometry: GeometryProxy) -> some View {
		HStack {
			Button {
				//TODO: Support
			} label: {
				Image(systemName: "backward.fill")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			Button {
				playbackState.isPlaying.toggle()
			} label: {
				let isPlaying = song.isNotPlaying == false && playbackState.isPlaying
				Image(systemName: isPlaying ? "pause.fill" : "play.fill")
					.contentTransition(.symbolEffect(.replace))
			}
			.font(.system(size: 50, weight: .bold))
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
			Button {
				//TODO: Support
			} label: {
				Image(systemName: "forward.fill")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
		}
		.font(.system(size: 30, weight: .regular))
		.padding([.bottom], geometry.size.height * 20.0 / 896.0)
	}
	
	@ViewBuilder
	func volumeControls(with geometry: GeometryProxy) -> some View {
		HStack {
			Image(systemName: "speaker.fill")
			Slider(value: $playbackState.volume)
			Image(systemName: "speaker.wave.2.fill")
		}
		.font(.footnote)
		.foregroundColor(.secondary)
	}
	
	@ViewBuilder
	func secondaryControls(with geometry: GeometryProxy) -> some View {
		HStack {
			Button(action: {}, label: {
				Image(systemName: "shuffle")
			})
			.frame(minWidth: 0, maxWidth: .infinity)
			Button(action: {}, label: {
				Image(systemName: "airplayaudio")
			})
			.frame(minWidth: 0, maxWidth: .infinity)
			Button(action: {}, label: {
				Image(systemName: "repeat")
			})
			.frame(minWidth: 0, maxWidth: .infinity)
		}
		.font(.body)
	}
	
	@State var selectedPopupItemIdentifier = ""
	
	func popupItem(for song: RandomTitleSong) -> PopupItem<RandomTitleSong, String, String, some ToolbarContent> {
		PopupItem(id: song, title: song.title, subtitle: song.albumName, image: Image(song.imageName), progress: playbackState.progress) {
			let isPlaying = song.isNotPlaying == false && playbackState.isPlaying
			
			ToolbarItem(placement: .popupBar) {
				HStack(spacing: 20) {
					Button {
						playbackState.isPlaying.toggle()
					} label: {
						Image(systemName: isPlaying ? "pause.fill" : "play.fill")
					}
					.accessibilityLabel(isPlaying ? "Pause" : "Play")
					.frame(minWidth: popupBarPlacement == .inline ? nil : 30)
					.disabled(song.isNotPlaying)
					
					if popupBarPlacement != .inline {
						Button {
							print("Next")
						} label: {
							Image(systemName: "forward.fill")
						}
						.accessibilityLabel("Next")
						.frame(minWidth: 30)
						.disabled(song.isNotPlaying)
					}
				}
				.animation(.spring(duration: 0.1), value: popupBarPlacement)
				.contentTransition(.symbolEffect(.replace))
			}
		}
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				albumArtImage(with: geometry)
				VStack(spacing: geometry.size.height * 30.0 / 896.0) {
					titles(with: geometry)
					slider(with: geometry)
					playbackControls(with: geometry)
					volumeControls(with: geometry)
					secondaryControls(with: geometry)
				}
				.disabled(song.isNotPlaying)
				.padding(geometry.size.height * 40.0 / 896.0)
			}
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   minHeight: 0,
				   maxHeight: .infinity,
				   alignment: .top)
			.background {
				ZStack {
					ZStack {
						Image(song.imageName)
							.resizable()
						Color(uiColor: .systemBackground)
							.opacity(0.4)
					}.compositingGroup().blur(radius: 90, opaque: true)
				}.edgesIgnoringSafeArea(.all)
			}
		}
		.onChange(of: song) {
			playbackState.progress = Float.random(in: 0.15...0.85)
		}
		.tint(.white)
		.environment(\.colorScheme, .dark)
		
		// A single popup item:
//		.popupItem {
//			popupItem(for: song)
//		}
		
		// A popup item list of all songs, with paging support:
		.popupItems(selection: $song) {
			if let currentPlaylist {
				for song in currentPlaylist {
					popupItem(for: song)
				}
			} else {
				popupItem(for: song)
			}
		}
	}
}

@available(iOS 17.0, *)
#Preview {
	PlayerView(song: Binding.constant(RandomTitleSong(id: "12")), currentPlaylist: nil)
}
