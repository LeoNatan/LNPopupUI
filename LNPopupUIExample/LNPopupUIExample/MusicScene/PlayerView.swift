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

struct PlayerView: View {
	let song: RandomTitleSong
	@State var playbackProgress: Float = Float.random(in: 0..<1)
	@State var volume: Float = Float.random(in: 0..<1)
	@State var isPlaying: Bool = true
	
	init(song: RandomTitleSong) {
		self.song = song
	}
	
	@AppStorage(.transitionType, store: .settings) var transitionType: Int = 0
	
	var body: some View {
		GeometryReader { geometry in
			return VStack {
				Image(song.imageName)
					.resizable()
					.popupTransitionTarget()
					.aspectRatio(contentMode: .fit)
					.clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
					.shadow(color: .black.opacity(0.5), radius: 10)
					.padding([.leading, .trailing], 20)
					.padding([.top], geometry.size.height * 60 / 896.0)
				VStack(spacing: geometry.size.height * 30.0 / 896.0) {
					HStack {
						VStack(alignment: .leading) {
							Text(song.title)
								.font(.system(size: 20, weight: .bold))
							Text(song.subtitle)
								.font(.system(size: 20, weight: .regular))
						}
						.lineLimit(1)
						.frame(minWidth: 0,
							   maxWidth: .infinity,
							   alignment: .topLeading)
						Button {} label: {
							Image(systemName: "ellipsis.circle")
								.font(.title)
						}
					}
					if #available(iOS 14.0, *) {
						ProgressView(value: playbackProgress)
							.padding([.bottom], geometry.size.height * 30.0 / 896.0)
					} else {
						Slider(value: $playbackProgress)
							.padding([.bottom], geometry.size.height * 30.0 / 896.0)
					}
					HStack {
						Button {} label: {
							Image(systemName: "backward.fill")
						}.frame(minWidth: 0, maxWidth: .infinity)
						
						Button {
							isPlaying.toggle()
						} label: {
							Image(systemName: isPlaying ? "pause.fill" : "play.fill")
						}
						.font(.system(size: 50, weight: .bold))
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
						
						Button {} label: {
							Image(systemName: "forward.fill")
						}.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.system(size: 30, weight: .regular))
					.padding([.bottom], geometry.size.height * 20.0 / 896.0)
					HStack {
						Image(systemName: "speaker.fill")
						Slider(value: $volume)
						Image(systemName: "speaker.wave.2.fill")
					}
					.font(.footnote)
					.foregroundColor(.gray)
					HStack {
						Button {} label: {
							Image(systemName: "shuffle")
						}.frame(minWidth: 0, maxWidth: .infinity)
						
						Button {} label: {
							Image(systemName: "airplayaudio")
						}.frame(minWidth: 0, maxWidth: .infinity)
						
						Button {} label: {
							Image(systemName: "repeat")
						}.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.body)
				}
				.layoutPriority(1)
				.padding(geometry.size.height * 40.0 / 896.0)
			}
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   minHeight: 0,
				   maxHeight: .infinity,
				   alignment: .top)
			.background({
				ZStack {
					Image(song.imageName)
						.resizable()
						.aspectRatio(contentMode: .fill)
					Color(uiColor: .systemBackground)
						.opacity(0.55)
				}.compositingGroup().blur(radius: 90)
				.edgesIgnoringSafeArea(.all)
			}())
		}
		.popupTitle(song.title)
		.popupImage(Image(song.imageName).resizable())
		.popupProgress(playbackProgress)
		.popupBarItems({
			Button {
				isPlaying.toggle()
			} label: {
				Image(systemName: isPlaying ? "pause.fill" : "play.fill")
			}
			
			Button {
				print("Next")
			} label: {
				Image(systemName: "forward.fill")
			}
		})
	}
}

struct PlayerView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerView(song: RandomTitleSong(id: 12))
	}
}
