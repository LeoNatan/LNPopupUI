//
//  TabNavView.swift
//  LNPopupUIExample
//
//  Created by Léo Natan on 2020-09-06.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI
import LoremIpsum
import LNPopupUI
import SwiftUIIntrospect

@available(iOS 18.0, *)
struct TabViewStylePad18Modifier: ViewModifier {
	@AppStorage(.tabBarHasSidebar, store: .settings) var tabBarHasSidebar: Bool = true
	
	func body(content: Content) -> some View {
		if tabBarHasSidebar {
			content.tabViewStyle(.sidebarAdaptable)
		} else {
			content.tabViewStyle(.tabBarOnly)
		}
	}
}

extension View {
	func tabViewStylePad18() -> some View {
		if #available(iOS 18.0, *) {
			return self.modifier(TabViewStylePad18Modifier())
		} else {
			return self
		}
	}
}

nonisolated(unsafe) private let key = malloc(1)!

struct InnerNavView : View {
	let tabIdx: Int
	let onDismiss: () -> Void
	
	let presentBarHandler: () -> Void
	let hideBarHandler: () -> Void
	
	var body: some View {
		MaterialNavigationStack {
			let bottomButtonsHandlers = SafeAreaDemoView.BottomButtonHandlers(presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
			let bottomBarHideSupport = SafeAreaDemoView.BottomBarHideSupport(showsBottomBarHideButton: true, isBottomBarTab: true)
			
			SafeAreaDemoView(colorSeed: "tab_\(tabIdx)", includeLink: true, bottomButtonsHandlers: bottomButtonsHandlers, showDismissButton: true, onDismiss: onDismiss, bottomBarHideSupport: bottomBarHideSupport)
				.navigationBarTitle(NSLocalizedString("LNPopupUI", comment: ""))
				.navigationBarTitleDisplayMode(.inline)
				.introspect(.tabView, on: .iOS(.v18, .v26), scope: .ancestor) { tvc in
					if #available(iOS 18.0, *) {
						if objc_getAssociatedObject(tvc, key) as? Bool != true {
							tvc.sidebar.isHidden = true
							objc_setAssociatedObject(tvc, key, NSNumber(booleanLiteral: true), .OBJC_ASSOCIATION_RETAIN)
						}
					}
				}
				.navigationBarBackButtonHidden(true)
		}
	}
}

struct TabGeneratorView<Content>: View where Content: View {
	let tabContentGenerator: (Int) -> Content
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@AppStorage(.tabBarHasSidebar, store: .settings) var tabBarHasSidebar: Bool = true
	
	@Binding var isBarPresented: Bool
	let demoContent: DemoContent
	
	init(demoContent: DemoContent, isBarPresented: Binding<Bool>, @ViewBuilder tabContentGenerator: @escaping (Int) -> Content) {
		self.demoContent = demoContent
		self._isBarPresented = isBarPresented
		self.tabContentGenerator = tabContentGenerator
	}
	
	var body: some View {
		if #available(iOS 18.0, *) {
			MaterialTabView {
				ForEach(1..<5) { idx in
					Tab("Tab\(UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular ? " \(idx)" : "")", systemImage: "\(idx).square") {
						tabContentGenerator(idx - 1)
					}
				}
				if tabBarHasSidebar && UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular {
					ForEach(5..<9) { idx in
						Tab("Sidebar Tab\(UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular ? " \(idx)" : "")", systemImage: "\(idx).square") {
							tabContentGenerator(idx - 1)
						}
						.tabPlacement(.sidebarOnly)
					}
				}
			}
			.tabViewStylePad18()
			.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		} else {
			MaterialTabView {
				ForEach(1..<5) { idx in
					tabContentGenerator(idx - 1)
						.tabItem {
							Label("Tab", systemImage: "\(idx).square").foregroundStyle(.red)
						}
				}
			}
			.popupDemo(demoContent: demoContent, isBarPresented: $isBarPresented, includeContextMenu: UserDefaults.settings.bool(forKey: .contextMenuEnabled))
		}
	}
}

struct TabNavView: View {
	let demoContent: DemoContent
	let onDismiss: () -> Void
	@State var isBarPresented: Bool = true
	
	func presentBarHandler() {
		isBarPresented = true
	}
	
	func hideBarHandler() {
		isBarPresented = false
	}
	
	var body: some View {
		TabGeneratorView(demoContent: demoContent, isBarPresented: $isBarPresented, tabContentGenerator: { idx in
			InnerNavView(tabIdx:idx, onDismiss: onDismiss, presentBarHandler: presentBarHandler, hideBarHandler: hideBarHandler)
		})
	}
}

struct TabNavView_Previews: PreviewProvider {
	static var previews: some View {
		TabNavView(demoContent: DemoContent(), onDismiss: {})
	}
}
