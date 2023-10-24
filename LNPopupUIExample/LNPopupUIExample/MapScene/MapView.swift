//
//  MapView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/3/20.
//

import SwiftUI
import MapKit

struct EnlargingButton: View {
	let label: String
	let action: (Bool) -> Void
	@State var pressed: Bool = false
	
	init(label: String, perform action: @escaping (Bool) -> Void) {
		self.label = label
		self.action = action
	}
	
	var body: some View {
		return Text(label)
			.font(.title)
			.foregroundColor(.white)
			.padding(10)
			.background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
			.scaleEffect(self.pressed ? 1.2 : 1.0)
			.onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
				withAnimation(.easeInOut) {
					self.pressed = pressing
					self.action(pressing)
				}
			}, perform: { })
	}
}

extension CLLocationCoordinate2D: Equatable {
	static public func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
}

extension MKCoordinateSpan: Equatable {
	static public func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.longitudeDelta == rhs.longitudeDelta && lhs.latitudeDelta == rhs.latitudeDelta
	}
}

extension MKCoordinateRegion: Equatable {
	public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
		return lhs.center == rhs.center && lhs.span == rhs.span
	}
}

struct CustomBarMapView: View {
	@Environment(\.colorScheme) var colorScheme
	
	static private let center = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445)
	static private let defaultRegion = MKCoordinateRegion(center: CustomBarMapView.center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
	
	static private let zoomedRegion = MKCoordinateRegion(center: CustomBarMapView.center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
	
	@State private var region = CustomBarMapView.defaultRegion
	
	let popupContentController: UIViewController
	
	private let onDismiss: () -> Void
	
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		
		popupContentController = LNUIKitPopupContentController()
	}
	
	@State var input: String = ""
	@State var isPopupOpen: Bool = false
	
	var body: some View {
		ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
			Map(coordinateRegion: $region)
				.ignoresSafeArea()
				.animation(.easeInOut, value: region)
			Button(action: {
				onDismiss()
			}, label: {
				Image(systemName: "chevron.left")
					.renderingMode(.template)
					.font(.title2)
			})
			.buttonStyle(MyButtonStyle(colorScheme: colorScheme))
			.padding()
		}
		.popup(isBarPresented: Binding.constant(true), isPopupOpen: $isPopupOpen, popupContentController: popupContentController)
		.popupBarCustomView(wantsDefaultTapGesture: false, wantsDefaultPanGesture: false, wantsDefaultHighlightGesture: false) {
			ZStack(alignment: .trailing) {
				HStack {
					Spacer()
					EnlargingButton(label: "Zoom") { pressing in
						self.region = pressing ? CustomBarMapView.zoomedRegion : CustomBarMapView.defaultRegion
					}.padding()
					Spacer()
					
				}
				Button(action: {
					isPopupOpen.toggle()
				}, label: {
					Image(systemName: "chevron.up")
						.renderingMode(.template)
				})
				.buttonStyle(MyButtonStyle(colorScheme: colorScheme))
				.padding()
			}
		}
		.font(nil)
	}
}

struct MyButtonStyle: ButtonStyle {
	let colorScheme: ColorScheme
	
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.font(.title2)
			.frame(width: 15, height: 15, alignment: .center)
			.padding(10)
			.foregroundColor(.white)
			.background(configuration.isPressed ? Color(red: 116 / 255.0, green: 185 / 255.0, blue: 1.0) : Color.blue)
			.cornerRadius(10.0)
	}
	
}

struct MapView_Previews: PreviewProvider {
	static var previews: some View {
		CustomBarMapView(onDismiss: {})
	}
}
