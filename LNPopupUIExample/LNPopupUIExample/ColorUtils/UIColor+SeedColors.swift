//
//  Color+SeedColors.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 10/31/20.
//

import SwiftUI

extension UIColor {
	fileprivate class func lightColor(withSeed seed: String) -> UIColor {
		srand48(seed.hash)
		
		let hue = CGFloat(drand48())
		let saturation = CGFloat(0.5)
		let brightness = CGFloat(1.0 - 0.25 * drand48())
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
	}
	
	fileprivate class func darkColor(withSeed seed: String) -> UIColor {
		srand48(seed.hash)
		
		let hue = CGFloat(drand48())
		let saturation = CGFloat(0.5)
		let brightness = CGFloat(0.3 + 0.25 * drand48())
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
	}
	
	class func adaptiveColor(withSeed seed: String) -> UIColor {
		if UserDefaults.standard.bool(forKey: __LNPopupBarDisableDemoSceneColors) {
			return .systemBackground
		}
		
		let light = lightColor(withSeed: seed)
		let dark = darkColor(withSeed: seed)
		
		return UIColor { traitCollection -> UIColor in
			if traitCollection.userInterfaceStyle == .dark {
				return dark
			}
			
			return light
		}
	}
}
