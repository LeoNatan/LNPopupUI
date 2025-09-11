//
//  LNUIKitPopupContentController.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-11.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import UIKit

class LNUIKitPopupContentController : UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		let label = UILabel()
		label.numberOfLines = 0
		label.text = NSLocalizedString("UIKit Popup Content Controller", comment: "")
		label.font = .preferredFont(forTextStyle: .title1)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(label)
		NSLayoutConstraint.activate([
			self.view.centerXAnchor.constraint(equalTo: label.centerXAnchor),
			self.view.centerYAnchor.constraint(equalTo: label.centerYAnchor),
		])
	}
}
