//
//  ConstraintsDemoView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan (Wix) on 9/5/20.
//

import SwiftUI

struct ConstraintsDemoView : View {
	let includeLink: Bool
	
	init(includeLink: Bool = true) {
		self.includeLink = includeLink
	}
	
	var body: some View {
		ZStack(alignment: .trailing) {
			VStack {
				Text("Top")
				Spacer()
				Text("Center")
				Spacer()
				Text("Bottom")
			}.frame(minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					maxHeight: .infinity,
					alignment: .top)
			if includeLink {
				NavigationLink("Next ▸", destination: ConstraintsDemoView().navigationTitle("LNPopupUI"))
					.padding()
			}
		}
		.padding(4)
		.font(.system(.headline))
	}
}
