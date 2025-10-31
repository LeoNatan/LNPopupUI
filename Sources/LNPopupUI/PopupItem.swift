//
//  PopupItem.swift
//  LNPopupUI
//
//  Created by Léo Natan on 25/10/25.
//

import SwiftUI

/// A protocol for compatible popup item image types. Currently, only SwiftUI `Image` and ``PopupItemImage`` are supported.
public
protocol PopupItemImageType {}

extension SwiftUI.Image: PopupItemImageType {}

/// A popup item image that will be displayed in a popup bar.
public
struct PopupItemImage: PopupItemImageType {
	/// The image that will be displayed in the popup bar.
	public
	let image: SwiftUI.Image?
	/// Will the image be displayed as resizable.
	public
	let resizable: Bool
	/// The ratio of width to height to use for the resulting popup bar image.
	public
	let aspectRatio: CGFloat?
	/// A flag that indicates whether this image fits or fills the popup bar image view.
	public
	let contentMode: ContentMode
	
	/// Creates a popup image based on a SwiftUI `Image` with settings modifying the presentation on a popup bar.
	/// - Parameters:
	///   - image: The image to use.
	///   - resizable: Mark the image as resizable. Defaults to `true`. If you'd like to control this on your own, set this parameter to `false`.
	///   - aspectRatio: The ratio of width to height to use for the resulting popup bar image. Use `nil` to maintain the current aspect ratio.
	///   - contentMode: A flag that indicates whether this image fits or fills the popup bar image view.
	public
	init(_ image: Image?, resizable: Bool = true, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) {
		self.image = image
		self.resizable = resizable
		self.aspectRatio = aspectRatio
		self.contentMode = contentMode
	}
}

/// A model that represents an item which can be displayed in a popup bar.
public
struct PopupItem<Identifier: Hashable, TitleContent, SubtitleContent, ButtonToolbarContent: ToolbarContent>: Identifiable {
	/// The stable identity of the popup item
	public
	let id: Identifier
	
	let titleContainer: TitleContainer<TitleContent, SubtitleContent>
	let image: PopupItemImageType?
	let buttonContainer: ButtonContainer<ButtonToolbarContent>
	let progress: Float?
}

public
extension PopupItem where TitleContent == String, SubtitleContent == String {
	/// Creates a popup item with a localized string title and subtitle.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The key for a popup item title string in the table identified by `tableName`.
	///   - subtitle: An optional key for a popup item subtitle string in the table identified by `tableName`.
	///   - tableName: The name of the string table to search. If `nil`, use the table in the `Localizable.strings` file.
	///   - bundle: The bundle containing the strings file. If `nil`, use the main bundle.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	init(id: Identifier, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, tableName: String? = nil, bundle: Bundle? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) {
		let subtitleToUse: String?
		if let subtitle {
			subtitleToUse = NSLocalizedString(subtitle.stringKey, tableName: tableName, bundle: bundle ?? .main, value: subtitle.stringKey, comment: "")
		} else {
			subtitleToUse = nil
		}
		
		let titleToUse = NSLocalizedString(title.stringKey, tableName: tableName, bundle: bundle ?? .main, value: title.stringKey, comment: "")
		
		self.init(id: id, titleContainer: StringTitleContainer(titleToUse, subtitleToUse), image: image, buttons: buttons(), progress: progress, private: ())
	}
	
	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	@_disfavoredOverload
	init<S>(id: Identifier, title: S, subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) where S: StringProtocol {
		
		self.init(id: id, titleContainer: StringTitleContainer(String(title), subtitle != nil ? String(subtitle!) : nil), image: image, buttons: buttons(), progress: progress, private: ())
	}
	
	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	init<S>(id: Identifier, verbatimTitle title: S, verbatimSubtitle subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) where S: StringProtocol {
		self.init(id: id, title: title, subtitle: subtitle, image: image, progress: progress, buttons: buttons)
	}
	
	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	init(id: Identifier, verbatimTitle title: String, verbatimSubtitle subtitle: String? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) {
		self.init(id: id, title: title, subtitle: subtitle, image: image, progress: progress, buttons: buttons)
	}
}

@available(iOS 15, *)
public
extension PopupItem where TitleContent == AttributedString, SubtitleContent == AttributedString {
	/// Creates a popup item with an attributed string title and subtitle.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: An attributed string to style and display as the popup item title, in accordance with its attributes.
	///   - subtitle: An optional attributed string to style and display as the popup item subtitle, in accordance with its attributes.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	init(id: Identifier, title: AttributedString, subtitle: AttributedString? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) {
		self.init(id: id, titleContainer: AttributedStringTitleContainer(title, subtitle), image: image, buttons: buttons(), progress: progress, private: ())
	}
}

public
extension PopupItem where TitleContent: View, SubtitleContent: View {
	/// Creates a popup item with custom title and subtitle views.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - title: A `ViewBuilder` that you use to declare the views to draw as the popup item's tile.
	///   - subtitle: An optional `ViewBuilder` that you use to declare the views to draw as the popup item's subtitle.
	///   - buttons: Optional bar buttons of the popup item.
	@_disfavoredOverload
	init(id: Identifier, image: PopupItemImageType? = nil, progress: Float? = nil, @ViewBuilder title: () -> TitleContent, @ViewBuilder subtitle: () -> SubtitleContent = { EmptyView() }, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) {
		self.init(id: id, titleContainer: ViewTitleContainer(title(), subtitle()), image: image, buttons: buttons(), progress: progress, private: ())
	}
}

public
extension PopupItem where TitleContent: View & Equatable, SubtitleContent: View & Equatable {
	/// Creates a popup item with custom title and subtitle views.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - title: A `ViewBuilder` that you use to declare the views to draw as the popup item's tile.
	///   - subtitle: An optional `ViewBuilder` that you use to declare the views to draw as the popup item's subtitle.
	///   - buttons: Optional bar buttons of the popup item.
	init(id: Identifier, image: PopupItemImageType? = nil, progress: Float? = nil, @ViewBuilder title: () -> TitleContent, @ViewBuilder subtitle: () -> SubtitleContent = { EquatableEmptyView() }, @ToolbarContentBuilder buttons: () -> ButtonToolbarContent = { emptyToolbarItem() }) {
		self.init(id: id, titleContainer: EquatableViewTitleContainer(title(), subtitle()), image: image, buttons: buttons(), progress: progress, private: ())
	}
}

/// A type-erased popup item.
public
struct AnyPopupItem {
	internal
	let base: any PopupItemProtocol
	
	/// Creates a type-erased popup item that wraps the given instance.
	/// - Parameter base: A popup item to wrap.
	public
	init<Identifier: Hashable, TitleContent, SubtitleContent, ButtonToolbarContent: ToolbarContent>(_ base: PopupItem<Identifier, TitleContent, SubtitleContent, ButtonToolbarContent>) {
		self.base = base
	}
}
