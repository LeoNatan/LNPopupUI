//
//  SettingsView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 3/19/21.
//

import SwiftUI

fileprivate struct SettingsViewInternal: UIViewControllerRepresentable {
	private let settingsController = SettingsTableViewController.new()
	
	func reset() {
		settingsController.reset()
	}
	
	func makeUIViewController(context: Context) -> SettingsTableViewController {
		return settingsController
	}
	
	func updateUIViewController(_ uiViewController: SettingsTableViewController, context: Context) {
		
	}
}

struct SettingsView: View {
	fileprivate let internalSettings = SettingsViewInternal()
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		NavigationView {
			internalSettings
				.ignoresSafeArea()
				.navigationTitle("Settings")
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button("Reset") {
							internalSettings.reset()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							self.presentationMode.wrappedValue.dismiss()
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)
		}
		.navigationViewStyle(.stack)
		
	}
}
