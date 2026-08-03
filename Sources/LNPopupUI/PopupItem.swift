//
//  PopupItem.swift
//  LNPopupUI
//
//  Created by Léo Natan on 25/10/25.
//  Copyright © 2020-2025 Léo Natan. All rights reserved.
//

import SwiftUI

/// A protocol for compatible popup item image types. Currently, only SwiftUI `Image` and `PopupItemImage` are supported.
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

// MARK: - Popup Item

/// A model that represents an item which can be displayed in a popup bar.
@MainActor public
struct PopupItem<Identifier: Hashable>: @MainActor Identifiable {
	/// The stable identity of the popup item
	public
	let id: Identifier

	let titleContainer: TitleContainer
	let image: PopupItemImageType?
	let buttonContainer: ButtonContainer
	let progress: Float?

	internal
	init(id: Identifier, titleContainer: TitleContainer, image: PopupItemImageType?, buttonContainer: ButtonContainer, progress: Float?) {
		self.id = id
		self.titleContainer = titleContainer
		self.image = image
		self.buttonContainer = buttonContainer
		self.progress = progress
	}
}

// MARK: Initializers with Trailing Bar Buttons

public
extension PopupItem {
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
    @_disfavoredOverload
	init<Trailing: ToolbarContent>(id: Identifier, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, tableName: String? = nil, bundle: Bundle? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		let subtitleToUse: String?
		if let subtitle {
			subtitleToUse = NSLocalizedString(subtitle.stringKey, tableName: tableName, bundle: bundle ?? .main, value: subtitle.stringKey, comment: "")
		} else {
			subtitleToUse = nil
		}

		let titleToUse = NSLocalizedString(title.stringKey, tableName: tableName, bundle: bundle ?? .main, value: title.stringKey, comment: "")

		self.init(id: id, titleContainer: StringTitleContainer(titleToUse, subtitleToUse), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
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
	init<S, Trailing: ToolbarContent>(id: Identifier, title: S, subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> Trailing = { EmptyPopupToolbarContent() }) where S: StringProtocol {
		self.init(id: id, titleContainer: StringTitleContainer(String(title), subtitle != nil ? String(subtitle!) : nil), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
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
    init<S, Trailing: ToolbarContent>(id: Identifier, verbatimTitle title: S, verbatimSubtitle subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> Trailing = { EmptyPopupToolbarContent() }) where S: StringProtocol {
		self.init(id: id, titleContainer: StringTitleContainer(String(title), subtitle != nil ? String(subtitle!) : nil), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
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
    init<Trailing: ToolbarContent>(id: Identifier, verbatimTitle title: String, verbatimSubtitle subtitle: String? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		self.init(id: id, titleContainer: StringTitleContainer(title, subtitle), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
	}

	/// Creates a popup item with custom title and subtitle views.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - title: A `ViewBuilder` that you use to declare the views to draw as the popup item's tile.
	///   - subtitle: An optional `ViewBuilder` that you use to declare the views to draw as the popup item's subtitle.
	///   - buttons: Optional bar buttons of the popup item.
    @_disfavoredOverload
    init<TitleContent: View, SubtitleContent: View, Trailing: ToolbarContent>(id: Identifier, image: PopupItemImageType? = nil, progress: Float? = nil, @ViewBuilder title: () -> TitleContent, @ViewBuilder subtitle: () -> SubtitleContent = { EmptyView() }, @ToolbarContentBuilder buttons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		self.init(id: id, titleContainer: ViewTitleContainer(titleView: AnyView(title()), subtitleView: AnyView(subtitle())), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
	}
}

@available(iOS 15, *)
public
extension PopupItem {
	/// Creates a popup item with an attributed string title and subtitle.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: An attributed string to style and display as the popup item title, in accordance with its attributes.
	///   - subtitle: An optional attributed string to style and display as the popup item subtitle, in accordance with its attributes.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - buttons: Optional bar buttons of the popup item.
	@_disfavoredOverload
	init<Trailing: ToolbarContent>(id: Identifier, title: AttributedString, subtitle: AttributedString? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder buttons: () -> Trailing) {
		self.init(id: id, titleContainer: AttributedStringTitleContainer(title, subtitle), image: image, buttonContainer: makeButtonContainer(buttons: buttons()), progress: progress)
	}
}

// MARK: Initializers with Leading and Trailing Bar Buttons

public
extension PopupItem {
	/// Creates a popup item with a localized string title and subtitle.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The key for a popup item title string in the table identified by `tableName`.
	///   - subtitle: An optional key for a popup item subtitle string in the table identified by `tableName`.
	///   - tableName: The name of the string table to search. If `nil`, use the table in the `Localizable.strings` file.
	///   - bundle: The bundle containing the strings file. If `nil`, use the main bundle.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	init<Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, tableName: String? = nil, bundle: Bundle? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		let subtitleToUse: String?
		if let subtitle {
			subtitleToUse = NSLocalizedString(subtitle.stringKey, tableName: tableName, bundle: bundle ?? .main, value: subtitle.stringKey, comment: "")
		} else {
			subtitleToUse = nil
		}

		let titleToUse = NSLocalizedString(title.stringKey, tableName: tableName, bundle: bundle ?? .main, value: title.stringKey, comment: "")

		self.init(id: id, titleContainer: StringTitleContainer(titleToUse, subtitleToUse), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}

	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	@_disfavoredOverload
	init<S, Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, title: S, subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) where S: StringProtocol {
		self.init(id: id, titleContainer: StringTitleContainer(String(title), subtitle != nil ? String(subtitle!) : nil), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}

	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	init<S, Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, verbatimTitle title: S, verbatimSubtitle subtitle: S? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) where S: StringProtocol {
		self.init(id: id, titleContainer: StringTitleContainer(String(title), subtitle != nil ? String(subtitle!) : nil), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}

	/// Creates a popup item with a string title and subtitle without localization.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: The title of the popup item.
	///   - subtitle: An optional subtitle of the popup item.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	init<Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, verbatimTitle title: String, verbatimSubtitle subtitle: String? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		self.init(id: id, titleContainer: StringTitleContainer(title, subtitle), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}

	/// Creates a popup item with custom title and subtitle views.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - title: A `ViewBuilder` that you use to declare the views to draw as the popup item's tile.
	///   - subtitle: An optional `ViewBuilder` that you use to declare the views to draw as the popup item's subtitle.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	init<TitleContent: View, SubtitleContent: View, Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, image: PopupItemImageType? = nil, progress: Float? = nil, @ViewBuilder title: () -> TitleContent, @ViewBuilder subtitle: () -> SubtitleContent = { EmptyView() }, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		self.init(id: id, titleContainer: ViewTitleContainer(titleView: AnyView(title()), subtitleView: AnyView(subtitle())), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}
}

@available(iOS 15, *)
public
extension PopupItem {
	/// Creates a popup item with an attributed string title and subtitle.
	/// - Parameters:
	///   - id: The popup item identifier.
	///   - title: An attributed string to style and display as the popup item title, in accordance with its attributes.
	///   - subtitle: An optional attributed string to style and display as the popup item subtitle, in accordance with its attributes.
	///   - image: An optional image of the popup item.
	///   - progress: An optional progress of the popup item.
	///   - leadingButtons: Optional leading bar buttons of the popup item.
	///   - trailingButtons: Optional trailing bar buttons of the popup item.
	@_disfavoredOverload
	init<Leading: ToolbarContent, Trailing: ToolbarContent>(id: Identifier, title: AttributedString, subtitle: AttributedString? = nil, image: PopupItemImageType? = nil, progress: Float? = nil, @ToolbarContentBuilder leadingButtons: () -> Leading = { EmptyPopupToolbarContent() }, @ToolbarContentBuilder trailingButtons: () -> Trailing = { EmptyPopupToolbarContent() }) {
		self.init(id: id, titleContainer: AttributedStringTitleContainer(title, subtitle), image: image, buttonContainer: makeButtonContainer(leadingButtons: leadingButtons(), trailingButtons: trailingButtons()), progress: progress)
	}
}

// MARK: - Default Popup Item Modifiers

/// Modifiers for the default popup item
///
/// These modifiers should be applied to the view inside the popup content.
public
extension View {
	/// Configures the default popup item's title and subtitle.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - localizedTitleKey: The localized title key to display.
	///   - localizedSubtitleKey: The localized subtitle key to display. Defaults to `nil`.
	///   - tableName: The name of the string table to search. If `nil`, use the table in the `Localizable.strings` file.
	///   - bundle: The bundle containing the strings file. If `nil`, use the main bundle.
	///   - titleComment: Contextual information about the title key-value pair.
	///   - subtitleComment: Contextual information about the subtitle key-value pair.
	func popupTitle(_ localizedTitleKey: LocalizedStringKey, subtitle localizedSubtitleKey: LocalizedStringKey? = nil, tableName: String? = nil, bundle: Bundle? = nil, titleComment: String? = nil, subtitleComment: String? = nil) -> some View {
		let subtitle: String?
		if let localizedSubtitleKey = localizedSubtitleKey {
			subtitle = NSLocalizedString(localizedSubtitleKey.stringKey, tableName: tableName, bundle: bundle ?? .main, value: localizedSubtitleKey.stringKey, comment: subtitleComment ?? "")
		} else {
			subtitle = nil
		}
		
		return popupTitle(verbatim: NSLocalizedString(localizedTitleKey.stringKey, tableName: tableName, bundle: bundle ?? .main, value: localizedTitleKey.stringKey, comment: titleComment ?? ""), subtitle: subtitle)
	}
	
	@_disfavoredOverload
	/// Configures the default popup item's title and subtitle.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - titleContent: The localized title key to display.
	///   - subtitleContent: The localized subtitle key to display. Defaults to `nil`.
	func popupTitle<S>(_ titleContent: S, subtitle subtitleContent: S? = nil) -> some View where S : StringProtocol {
		let subtitle: String?
		if let subtitleContent = subtitleContent {
			subtitle = String(subtitleContent)
		} else {
			subtitle = nil
		}
		
		return popupTitle(verbatim: String(titleContent), subtitle: subtitle)
	}
	
	/// Configures the default popup item's title and subtitle with custom views.
	///
	/// When using custom labels, marquee scroll and text attributes settings have no effect.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - titleContent: A view that describes the popup's title.
	///   - subtitleContent: A view that describes the popup's subtitle.
	func popupTitle<TitleContent, SubtitleContent>(@ViewBuilder _ titleContent: () -> TitleContent, @ViewBuilder subtitle subtitleContent: () -> SubtitleContent = { EmptyView() }) -> some View where TitleContent : View, SubtitleContent : View {
		preference(key: LNPopupTextTitlePreferenceKey.self, value: %%LNPopupTitleContentData(titleView: AnyView(erasing: titleContent()), subtitleView: AnyView(erasing: subtitleContent())))
	}
	
	/// Configures the default popup item's title and subtitle.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle<S>(verbatim title: S, subtitle: S? = nil) -> some View where S : StringProtocol {
		popupTitle(verbatim: String(title), subtitle: subtitle == nil ? nil : String(subtitle!))
	}
	
	/// Configures the default popup item's title and subtitle.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - title: The title to display.
	///   - subtitle: The subtitle to display. Defaults to `nil`.
	func popupTitle(verbatim title: String, subtitle: String? = nil) -> some View {
		preference(key: LNPopupTitlePreferenceKey.self, value: %%LNPopupTitleData(title: title, subtitle: subtitle))
	}
	
	/// Configures the default popup item's image.
	///
	/// Setting to `nil` will hide image from the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - image: The image to use.
	///   - resizable: Mark the image as resizable. Defaults to `true`. If you'd like to control this on your own, set this parameter to `false`.
	///   - aspectRatio: The ratio of width to height to use for the resulting popup bar image. Use `nil` to maintain the current aspect ratio.
	///   - contentMode: A flag that indicates whether this view fits or fills the popup bar image view.
	func popupImage(_ image: Image?, resizable: Bool = true, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) -> some View {
		if let image {
			preference(key: LNPopupImagePreferenceKey.self, value: %%LNPopupImageData(image: image, resizable: resizable, aspectRatio: aspectRatio, contentMode: contentMode))
		} else {
			preference(key: LNPopupImagePreferenceKey.self, value: nil)
		}
	}
	
	/// Configures the default popup item's progress.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameters:
	///   - progress: The popup bar progress.
	func popupProgress(_ progress: Float) -> some View {
		preference(key: LNPopupProgressPreferenceKey.self, value: %%progress)
	}
	
	/// Sets the bar buttons to display on the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: A view representing the bar buttons that appear on the popup bar.
	func popupBarButtons<Content>(@ViewBuilder _ content: () -> Content) -> some View where Content : View {
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(content))
	}
	
	/// Configures the default popup item's bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: Toolbar content representing the bar buttons that appear on the popup bar.
	@available(iOS, introduced: 14.0)
	func popupBarButtons<Content>(@ToolbarContentBuilder _ content: () -> Content) -> some View where Content : ToolbarContent {
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(content))
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	func popupBarLeadingButtons<LeadingContent>(@ViewBuilder leading: () -> LeadingContent) -> some View where LeadingContent: View {
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%barItemContainer(leading))
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading bar items are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	func popupBarLeadingButtons<LeadingContent>(@ToolbarContentBuilder leading: () -> LeadingContent) -> some View where LeadingContent: ToolbarContent {
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%barItemContainer(leading))
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	func popupBarTrailingButtons<TrailingContent>(@ViewBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: View {
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(trailing))
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	func popupBarTrailingButtons<TrailingContent>(@ToolbarContentBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: ToolbarContent {
		return preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(trailing))
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	func popupBarButtons<LeadingContent, TrailingContent>(@ViewBuilder leading: () -> LeadingContent, @ViewBuilder trailing: () -> TrailingContent) -> some View where LeadingContent: View, TrailingContent: View {
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%barItemContainer(leading))
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(trailing))
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	func popupBarButtons<LeadingContent, TrailingContent>(@ToolbarContentBuilder leading: () -> LeadingContent, @ToolbarContentBuilder trailing: () -> TrailingContent) -> some View where LeadingContent: ToolbarContent, TrailingContent: ToolbarContent {
		return preference(key: LNPopupLeadingBarItemsPreferenceKey.self, value: %%barItemContainer(leading))
			.preference(key: LNPopupTrailingBarItemsPreferenceKey.self, value: %%barItemContainer(trailing))
	}
}

// MARK: - Utils

@resultBuilder public
struct PopupItemBuilder<Identifier: Hashable> {
	public static
	func buildBlock(_ components: [PopupItem<Identifier>]...) -> [PopupItem<Identifier>] { components.flatMap { $0 } }

	public static
	func buildExpression(_ expression: PopupItem<Identifier>?) -> [PopupItem<Identifier>] { if let expression { [expression] } else { [] } }

	public static
	func buildExpression(_ expression: [PopupItem<Identifier>]) -> [PopupItem<Identifier>] { expression }

	public static
	func buildOptional(_ component: [PopupItem<Identifier>]?) -> [PopupItem<Identifier>] { component ?? [] }

	public static
	func buildEither(first component: [PopupItem<Identifier>]) -> [PopupItem<Identifier>] { component }

	public static
	func buildEither(second component: [PopupItem<Identifier>]) -> [PopupItem<Identifier>] { component }

	public static
	func buildArray(_ components: [[PopupItem<Identifier>]]) -> [PopupItem<Identifier>] { components.flatMap { $0 } }

	public static
	func buildLimitedAvailability(_ component: [PopupItem<Identifier>]) -> [PopupItem<Identifier>] { component }
}

// MARK: Deprecations

/// A type-erased popup item.
@available(*, deprecated, renamed: "PopupItem")
public typealias AnyPopupItem<Identifier: Hashable> = PopupItem<Identifier>

extension PopupItem {
    /// Creates a type-erased popup item that wraps the receiver.
    @available(*, deprecated, message: "No longer needed")
    public func eraseToAnyPopupItem() -> AnyPopupItem<Identifier> {
        return self
    }
}

/// Deprecations
public extension View {
	/// Configures the default popup item's bar buttons.
	///
	/// For compact popup bars, this is equivalent to trailing bar buttons.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: A view representing the bar buttons that appear on the popup bar.
	@available(*, deprecated, renamed: "popupBarButtons(_:)")
	func popupBarItems<Content>(@ViewBuilder _ content: () -> Content) -> some View where Content : View {
		popupBarButtons(content)
	}
	
	/// Configures the default popup item's bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For compact popup bars, this is equivalent to trailing bar buttons.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter content: Toolbar content representing the bar buttons that appear on the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarButtons(_:)")
	func popupBarItems<Content>(@ToolbarContentBuilder _ content: () -> Content) -> some View where Content : ToolbarContent {
		popupBarButtons(content)
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarLeadingButtons(_:)")
	func popupBarLeadingItems<LeadingContent>(@ViewBuilder leading: () -> LeadingContent) -> some View where LeadingContent: View {
		popupBarLeadingButtons(leading: leading)
	}
	
	/// Configures the default popup item's leading bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// For prominent popup bars, leading bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarLeadingButtons(_:)")
	func popupBarLeadingItems<LeadingContent>(@ToolbarContentBuilder leading: () -> LeadingContent) -> some View where LeadingContent: ToolbarContent {
		popupBarLeadingButtons(leading: leading)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarTrailingButtons(_:)")
	func popupBarTrailingItems<TrailingContent>(@ViewBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: View {
		popupBarTrailingButtons(trailing: trailing)
	}
	
	/// Configures the default popup item's trailing bar buttons.
	///
	/// Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarTrailingButtons(_:)")
	func popupBarTrailingItems<TrailingContent>(@ToolbarContentBuilder trailing: () -> TrailingContent) -> some View where TrailingContent: ToolbarContent {
		popupBarTrailingButtons(trailing: trailing)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: A view representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: A view representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(*, deprecated, renamed: "popupBarButtons(leading:trailing:)")
	func popupBarItems<LeadingContent, TrailingContent>(@ViewBuilder leading: () -> LeadingContent, @ViewBuilder trailing: () -> TrailingContent) -> some View where LeadingContent: View, TrailingContent: View {
		popupBarButtons(leading: leading, trailing: trailing)
	}
	
	/// Configures the default popup item's leading and trailing bar buttons.
	///
	/// @note Only `ToolbarItem` and `ToolbarItemGroup` with a `.popupBar` placements are supported. For prominent popup bars, leading and trailing bar buttons are positioned in the trailing edge of the popup bar.
	///
	/// - Note: You should never mix direct popup item specifier modifiers, such as `View.popupItem(_:)`, with default popup item modifiers in the same popup content hierarchy.
	/// - Parameter leading: Toolbar content representing the bar buttons that appear on the leading edge of the popup bar.
	/// - Parameter trailing: Toolbar content representing the bar buttons that appear on the trailing edge of the popup bar.
	@available(iOS, introduced: 14.0, deprecated, renamed: "popupBarButtons(leading:trailing:)")
	func popupBarItems<LeadingContent, TrailingContent>(@ToolbarContentBuilder leading: () -> LeadingContent, @ToolbarContentBuilder trailing: () -> TrailingContent) -> some View where LeadingContent: ToolbarContent, TrailingContent: ToolbarContent {
		popupBarButtons(leading: leading, trailing: trailing)
	}
}
