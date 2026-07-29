//
//  LNPopupController+LNPopupUIAdditions.swift
//  LNPopupUI
//
//  Created by Léo Natan on 2024-07-08.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import LNPopupController
import UIKit
import SwiftUI

public extension UIViewController {
	/// Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation.
	///
	/// The popup bar is attached to the receiver's docking view. See ``UIViewController/bottomDockingViewForPopupBar`` for more information on the bottom docking view.
	///
	/// - Parameters:
	///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	///   - openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
	///   - popupContent: The popup content view
	///   - completion: The closure to execute after the presentation finishes. This closure has no return value and takes no parameters. You may specify `nil` for this parameter.
	func presentPopupBar<PopupContent: View>(animated: Bool = true, openPopup: Bool = false, @ViewBuilder popupContent: () -> PopupContent, completion: (() -> Void)? = nil) {
		let controller = LNPopupContentHostingController(content: popupContent())
		presentPopupBar(with: controller, openPopup: openPopup, animated: animated, completion: completion)
	}
	
	/// Presents an interactive popup bar in the receiver's view hierarchy and optionally opens the popup in the same animation.
	///
	/// The popup bar is attached to the receiver's docking view. See ``UIViewController/bottomDockingViewForPopupBar`` for more information on the bottom docking view.
	///
	/// - Parameters:
	///   - popupContent: The popup content view
	///   - openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
	///   - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
	///   - completion: The closure to execute after the presentation finishes. This closure has no return value and takes no parameters. You may specify `nil` for this parameter.
	@available(iOS, introduced: 14.0, deprecated: 14.0, renamed: "presentPopupBar(animated:openPopup:popupContent:completion:)")
	func presentPopupBar<PopupContent: View>(@ViewBuilder with popupContent: () -> PopupContent, openPopup: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
		presentPopupBar(animated: animated, openPopup: openPopup, popupContent: popupContent, completion: completion)
	}
}
