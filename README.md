# LNPopupUI

`LNPopupUI` is a SwiftUI library for presenting views as popups, much like the Apple Music and Podcasts apps.

This is a SwiftUI wrapper of my [LNPopupController framework](https://github.com/LeoNatan/LNPopupController), adapted to work with SwiftUI.

[![GitHub release](https://img.shields.io/github/release/LeoNatan/LNPopupUI.svg)](https://github.com/LeoNatan/LNPopupUI/releases) [![GitHub stars](https://img.shields.io/github/stars/LeoNatan/LNPopupUI.svg)](https://github.com/LeoNatan/LNPopupUI/stargazers) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/LeoNatan/LNPopupUI/master/LICENSE) <span class="badge-paypal"><a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BR68NJEJXGWL6" title="Donate to this project using PayPal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg?style=flat" alt="PayPal Donation Button" /></a></span>

[![GitHub issues](https://img.shields.io/github/issues-raw/LeoNatan/LNPopupUI.svg)](https://github.com/LeoNatan/LNPopupUI/issues) [![GitHub contributors](https://img.shields.io/github/contributors/LeoNatan/LNPopupUI.svg)](https://github.com/LeoNatan/LNPopupUI/graphs/contributors) [![Swift Package Manager compatible](https://img.shields.io/badge/swift%20package%20manager-compatible-green)](https://swift.org/package-manager/)

<p align="center"><img src="./Supplements/open_modern_popup.gif" width="360"/></p>

See a video of the modern popup look & feel [here](https://vimeo.com/194064291) and a video of the classic popup look & feel [here](https://vimeo.com/137020302).

Once a popup bar is presented with a content view, the user can swipe or tap the popup at any point to present the content view. After finishing, the user dismisses the popup by either swiping or tapping the popup close button.

The library extends SwiftUI’s `View` with new functionality for presenting and opening popups with content views, as well as setting information such as the popup bar’s title, image and bar button items. When a popup is presented, the popup bar automatically adapts to the view it was presented on for best appearance.

Generally, it is recommended to present the popup bar on the outermost view, such as `TabView` or `NavigationView`. So if you have a view contained in a navigation view, which is in turn contained in a tab view, it is recommended to present the popup on the tab view.

Check the demo project for a quick recreation of Apple’s music app.

### Features

* Available for iOS 13 and above, as a SPM package for SwiftUI
* A SwiftUI library, wrapping my [LNPopupController framework](https://github.com/LeoNatan/LNPopupController); the library works internally with SwiftUI’s generated UIKit content to present the framework in a native manner

## Adding to Your Project

### Swift Package Manager

LNPopupUI supports SPM versions 5.1.0 (Xcode 11) and above. In Xcode, click `File` -> `Swift Packages` -> `Add Package Dependency`, enter `https://github.com/LeoNatan/LNPopupUI`. Select the version you’d like to use.

You can also manually add the package to your Package.swift file:

```swift
.package(url: "https://github.com/LeoNatan/LNPopupUI.git", from: "1.0.0")
```

And the dependency in your target:

```swift
.target(name: "BestExampleApp", dependencies: ["LNPopupUI"]),
```

## Using the Library

### Project Integration

Import the module in your project:

```swift
import LNPopupUI
```

### Popups

Popup consist of a popup bar and a popup content view. Information for the popup bar, such as the title, image and bar button items, is received by using the provided modifier API.

To present the popup, call the `popup(isBarPresented:isPopupOpen:content)` method:

```swift
TabView {
	//Top content view
}
.popup(isBarPresented: $isPopupBarPresented, isPopupOpen: $isPopupOpen) {
	PlayerView(song: currentSong)
}
```

<p align="center"><img src="./Supplements/modern_no_scroll.gif" width="360"/></p>

To present and dismiss the popup bar programmatically, toggle the `isPopupBarPresented` bound var. To open or close the popup programmatically, toggle the `isPopupOpen` bound var.

For more information, see the documentation in [LNPopupUI.swift](https://github.com/LeoNatan/LNPopupUI/blob/master/Sources/LNPopupUI/LNPopupUI.swift).

### Popup Bar Content

Popup bar content is provided as modifiers of the popup content view.

```swift
VStack {
	//Popup content view
}
.popupTitle(song.title)
.popupImage(Image(song.imageName))
.popupProgress(playbackProgress)
.popupBarItems({
	HStack(spacing: 20) {
		Button(action: {
			isPlaying.toggle()
		}) {
			Image(systemName: "play.fill")
		}

		Button(action: {
			next()
		}) {
			Image(systemName: "forward.fill")
		}
	}
})
```

### Appearance and Behavior

`LNPopupUI` provides two distinct style of popup look and feel, one based on modern Music app look and feel, and one based on the previous, iOS 9-style look and feel. Popup bar styles are arbitrarily labeled "prominent" for modern style popup bar and "compact" for iOS 9-style. Popup interaction styles are labeled "snap" for modern style snapping popups and "drag" for iOS 9 interactive popup interaction. Popup close buttons styles are labeled "chevron" for modern style chevron close button and "round" for iOS 9-style close buttons. For each, there is a "default" style for choosing the most suitable one for the current operating system version.

The defaults are:
* Prominent bar style
* Snap interaction style
* Chevron close button style
* No progress view style

#### Bar Style

Customizing the popup bar style is achieved by calling the `.popupBarStyle()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupBarStyle(.compact)
```

<p align="center"><img src="./Supplements/modern_no_scroll.gif" width="360"/> <img src="./Supplements/scroll.gif" width="360"/></p>

#### Interaction Style

Customizing the popup interaction style is achieved by calling the `.popupInteractionStyle()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupInteractionStyle(.drag)
```

<p align="center"><img src="./Supplements/interaction_snap.gif" width="360"/> <img src="./Supplements/interaction_drag.gif" width="360"/></p>

#### Progress View Style

Customizing the popup bar progress view style is achieved by calling the `.popupBarProgressViewStyle()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupBarProgressViewStyle(.top)
```

To hide the progress view, set the bar progress view style to `.none`.

<p align="center"><img src="./Supplements/progress_view_none.png" width="360"/><br/><br/><img src="./Supplements/progress_view_top.png" width="360"/><br/><br/><img src="./Supplements/progress_view_bottom.png" width="360"/></p>

#### Close Button Style

Customizing the popup close button style is achieved by calling the `.popupCloseButtonStyle()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupCloseButtonStyle(.round)
```

To hide the popup close button, set the `popupCloseButtonStyle` to `LNPopupCloseButtonStyleNone` / `.none`.

<p align="center"><img src="./Supplements/close_button_none.png" width="360"/><br/><br/><img src="./Supplements/close_button_chevron.png" width="360"/><br/><br/><img src="./Supplements/close_button_round.png" width="360"/></p>

#### Custom Popup Bar View

You can display your own view as the popup bar, instead of the system-provided ones, by using the `.popupBarCustomView()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupBarCustomView(wantsDefaultTapGesture: false, wantsDefaultPanGesture: false, wantsDefaultHighlightGesture: false) {
  //Custom popup bar view content
}
```

The `wantsDefaultTapGesture`, `wantsDefaultPanGesture` and `wantsDefaultHighlightGesture` arguments control whether the default system gestures of the popup bar should be enabled or disabled.

<p align="center"><img src="./Supplements/custom_bar.png" width="360"/></p>

#### Context Menus

You can add a context menu to your popup bar by calling the `.popupBarContextMenu()` modifier.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupBarContextMenu {
	Button(action: {
		print("Context Menu Item 1")
	}) {
		Text("Context Menu Item 1")
		Image(systemName: "globe")
	}
	
	Button(action: {
		print("Context Menu Item 2")
	}) {
		Text("Context Menu Item 2")
		Image(systemName: "location.circle")
	}
}
```

<p align="center"><img src="./Supplements/popup_bar_context_menu.png" width="360"/></p>

#### Lower-level Bar Customization

LNPopup exposes the `.popupBarCustomizer()` modifier, which allows lower-level customization through the UIKit `LNPopupBar` object.

```swift
.popup(isBarPresented: $isPopupPresented, isPopupOpen: $isPopupOpen) {
	//Popup content view
}
.popupBarCustomizer { popupBar in
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.alignment = .right
	paragraphStyle.lineBreakMode = .byTruncatingTail

	popupBar.inheritsVisualStyleFromDockingView = false
	popupBar.backgroundStyle = .dark
	popupBar.titleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFont(name: "Chalkduster", size: 14)!, .foregroundColor: UIColor.yellow ]
	popupBar.subtitleTextAttributes = [ .paragraphStyle: paragraphStyle, .font: UIFont(name: "Chalkduster", size: 12)!, .foregroundColor: UIColor.green ]
	popupBar.tintColor = .yellow
}
```

<p align="center"><img src="./Supplements/modern_custom.png" width="360"/> <img src="./Supplements/custom1.png" width="360"/></p>

#### Full Right-to-Left Support

The library has full right-to-left support.

<p align="center"><img src="./Supplements/rtl_english.png" width="360"/> <img src="./Supplements/rtl_hebrew.png" width="360"/></p>

## Acknowledgements

The library uses:
* [MarqueeLabel](https://github.com/cbpowell/MarqueeLabel) Copyright (c) 2011-2020 Charles Powell

Additionally, the demo project uses:

* [LoremIpsum](https://github.com/lukaskubanek/LoremIpsum) Copyright (c) 2013-2020 Lukas Kubanek
