//
//  DumbSearchView.swift
//  LNPopupUI
//
//  Created by Léo Natan on 1/10/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

struct DumbSearchView: View {
	@State var searchText: String = ""
	
    var body: some View {
		NavigationStack {
			Group {
				if #available(iOS 17, *) {
					ContentUnavailableView.search
				} else {
					EmptyView()
				}
			}.navigationTitle(NSLocalizedString("Search", comment: ""))
				.navigationBarTitleDisplayMode(.inline)
				.searchable(text: $searchText)
		}
    }
}
