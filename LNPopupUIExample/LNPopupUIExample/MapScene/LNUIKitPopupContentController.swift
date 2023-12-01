//
//  LNUIKitPopupContentController.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 9/11/20.
//

import UIKit

class LNUIKitPopupContentController : UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		let label = UILabel()
		label.numberOfLines = 0
		label.text = String(localized: "UIKit Popup Content Controller")
		label.font = .preferredFont(forTextStyle: .title1)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(label)
		NSLayoutConstraint.activate([
			self.view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
			self.view.centerYAnchor.constraint(equalTo: label.centerYAnchor),
		])
	}
}
