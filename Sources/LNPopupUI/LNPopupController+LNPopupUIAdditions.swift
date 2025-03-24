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
	func presentPopupBar<PopupContent: View>(@ViewBuilder with popupContent: @escaping () -> PopupContent, openPopup: Bool = false, animated: Bool, completion: (() -> Void)? = nil) {
		let controller: UIViewController = LNPopupContentHostingController(content: popupContent)
		presentPopupBar(with: controller, openPopup: openPopup, animated: animated, completion: completion)
	}
}
