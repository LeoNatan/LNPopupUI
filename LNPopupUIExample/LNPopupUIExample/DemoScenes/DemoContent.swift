//
//  DemoContent.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 11/24/20.
//

import Foundation
import LoremIpsum

struct DemoContent {
	let title = LoremIpsum.title
	let subtitle = LoremIpsum.sentence
	let imageNumber = Int.random(in: 1..<31)
}
