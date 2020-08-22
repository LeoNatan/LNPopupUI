//
//  PlayerView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import LNPopupUI
import LNPopupController
import LoremIpsum
import Combine

struct BlurView: UIViewRepresentable {
	var style: UIBlurEffect.Style = .systemMaterial
	func makeUIView(context: Context) -> UIVisualEffectView {
		return UIVisualEffectView(effect: UIBlurEffect(style: style))
	}
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = UIBlurEffect(style: style)
	}
}

struct PlayerView: View {
	let song: RandomTitleSong
	@State var playbackProgress: Float = Float.random(in: 0..<1)
	@State var volume: Float = Float.random(in: 0..<1)
	@State var isPlaying: Bool = true
	
	init(song: RandomTitleSong) {
		self.song = song
	}
	
	var body: some View {
		VStack {
			Image(song.imageName)
				.resizable()
				.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
				.aspectRatio(contentMode: .fit)
				.padding([.leading, .trailing], 20)
				.padding([.top], 40)
				.shadow(radius: 5)
			VStack(spacing: 40) {
				HStack {
					VStack(alignment: .leading) {
						Text(song.title)
						Text(song.subtitle)
					}
					.font(.title)
					.lineLimit(1)
					.frame(minWidth: 0,
						   maxWidth: .infinity,
						   alignment: .topLeading)
					Button(action: {}, label: {
						Image(systemName: "ellipsis.circle")
							.font(.title)
					})
				}
				Slider(value: $playbackProgress)
				HStack {
					Button(action: {}, label: {
						Image(systemName: "backward.fill")
					})
					.frame(minWidth: 0, maxWidth: .infinity)
					Button(action: {
						isPlaying.toggle()
					}, label: {
						Image(systemName: isPlaying ? "pause.fill" : "play.fill")
					})
					.frame(minWidth: 0, maxWidth: .infinity)
					Button(action: {}, label: {
						Image(systemName: "forward.fill")
					})
					.frame(minWidth: 0, maxWidth: .infinity)
				}
				.frame(height: 40)
				.font(.largeTitle)
				HStack {
					Image(systemName: "speaker.fill")
					Slider(value: $volume)
					Image(systemName: "speaker.wave.2.fill")
				}
				.font(.footnote)
				.foregroundColor(.gray)
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
			.padding(30)
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
				BlurView()
			}
			.ignoresSafeArea()
		}())
		.popupTitle(song.title)
		.popupImage(Image(song.imageName))
		.popupProgress(playbackProgress)
		.popupBarItems(leading: {
			HStack(spacing: 20) {
				Button(action: {
					isPlaying.toggle()
				}) {
					Image(systemName: isPlaying ? "pause.fill" : "play.fill")
				}
			}
		}, trailing: {
			HStack(spacing: 20) {
				Button(action: {
					print("Next")
				}) {
					Image(systemName: "forward.fill")
				}
			}
		})
//		.popupBarItems({
//			HStack(spacing: 20) {
//				Button(action: {
//					print("Play")
//				}) {
//					Image(systemName: "play.fill")
//				}
//
//				Button(action: {
//					print("Next")
//				}) {
//					Image(systemName: "forward.fill")
//				}
//			}
//		})
	}
}

struct PlayerView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerView(song: RandomTitleSong(id: 12))
	}
}
