//
//  Utils.swift
//  LNPopupUI
//
//  Created by Leo Natan on 9/20/21.
//

import SwiftUI

internal extension LocalizedStringKey {
	var stringKey: String {
		return Mirror(reflecting: self).children.first(where: { $0.label == "key" })!.value as! String
	}
}
