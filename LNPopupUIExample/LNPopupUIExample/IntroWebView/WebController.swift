//
//  WebController.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 10/14/20.
//

import UIKit
import WebKit

class WebController: UIViewController {
	private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		webView.load(URLRequest(url: URL(string: "https://github.com/LeoNatan/LNPopupUI")!))
		webView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(webView)
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: webView.topAnchor),
			view.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
		])
		
		popupItem.title = "Welcome to LNPopupUI"
		popupItem.image = UIImage(named: "genre10")
		popupItem.barButtonItems = [
			UIBarButtonItem(image: UIImage(systemName: "suit.heart.fill"), style: .done, target: nil, action: nil)
		]
    }
}
