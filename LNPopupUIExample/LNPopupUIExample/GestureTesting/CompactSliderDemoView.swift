//
//  CompactSliderDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 01/09/2023.
//

import SwiftUI
import CompactSlider

struct CompactSliderDemoView: View {
	@AppStorage("playbackRate") var playbackRate: Double = 1.0
	@AppStorage("playbackRate2") var playbackRate2: Double = 1.0
	@AppStorage("playbackRateFrom") var playbackRateFrom: Double = 4.0
	@AppStorage("playbackRateTo") var playbackRateTo: Double = 10.0
	@AppStorage("playbackRate5") var playbackRate5: Double = 1.0
	
	let onDismiss: () -> Void
	
    var body: some View {
		TabView{
			InnerView(tabIdx:0, onDismiss: onDismiss, presentBarHandler: nil, hideBarHandler: nil)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
			InnerView(tabIdx:1, onDismiss: onDismiss, presentBarHandler: nil, hideBarHandler: nil)
				.tabItem {
					Image(systemName: "star.fill")
					Text("Tab")
				}
		}.popup(isBarPresented: Binding.constant(true)) {
			Text("Hello, World!")
			CompactSlider(value: $playbackRate, in: 0.5...3, step: 0.1) {
				Spacer()
				Text("\(playbackRate)")
			}.padding()
			CompactSlider(value: $playbackRate2, in: 0.5...3, step: 0.1, direction: .center) {
				Spacer()
				Text("\(playbackRate2)")
			}.padding()
			CompactSlider(from: $playbackRateFrom, to: $playbackRateTo, in: 0...20, step: 1) {
				Spacer()
				Text("\(zeroLeadingHours(playbackRateFrom)) — \(zeroLeadingHours(playbackRateTo))")
			}.padding()
				.popupImage(Image("genre3"))
				.popupTitle("CompactSlider")
		}
    }
	
	private func zeroLeadingHours(_ value: Double) -> String {
		let hours = Int(value) % 24
		return "\(hours < 10 ? "0" : "")\(hours):00"
	}
}

#Preview {
	CompactSliderDemoView() {}
}
