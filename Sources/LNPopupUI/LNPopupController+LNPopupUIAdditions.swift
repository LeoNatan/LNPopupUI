//
//  LNPopupController+LNPopupUIAdditions.swift
//  LNPopupUI
//
//  Created by Léo Natan on 8/7/24.
//

import LNPopupController
import UIKit
import SwiftUI

public extension UIViewController {
	func presentPopupBar<PopupContent: View>(@ViewBuilder with popupContent: @escaping () -> PopupContent, openPopup: Bool = false, animated: Bool, completion: (() -> Void)? = nil) {
		let controller: UIViewController = LNPopupHostingContentController(content: popupContent)
		presentPopupBar(with: controller, openPopup: openPopup, animated: animated, completion: completion)
	}
}
