//
//  Utils.swift
//  LNPopupUI
//
//  Created by Leo Natan on 9/20/21.
//

import UIKit
import SwiftUI

internal extension LocalizedStringKey {
	var stringKey: String {
		return Mirror(reflecting: self).children.first(where: { $0.label == "key" })!.value as! String
	}
}

@objc(__LNPopupUI) fileprivate class __LNPopupUI: NSObject {}

@available(iOS 15, *)
internal extension AttributeContainer {
	var _swiftUIToUIKit: AttributeContainer {
		var rv = self
		if let font = rv.swiftUI.font, rv.uiKit.font == nil {
			rv.uiKit.font = font.toUIFont()
		}
		if let foregroundColor = rv.swiftUI.foregroundColor, rv.uiKit.foregroundColor == nil {
			rv.uiKit.foregroundColor = UIColor(foregroundColor)
		}
		if let backgroundColor = rv.swiftUI.backgroundColor, rv.uiKit.backgroundColor == nil {
			rv.uiKit.backgroundColor = UIColor(backgroundColor)
		}
		
		return rv
	}
}


extension Font {
	public init(uiFont: UIFont) {
		self.init(uiFont as CTFont)
	}
	
	public func toUIFont() -> UIFont? {
		var font: UIFont?
		
		inspect(self) { label, value in
			guard label == "provider" else { return }
			
			inspect(value) { label, value in
				guard label == "base" else { return }
				
				guard let provider = SwiftUIFontProvider(from: value) else {
					return assertionFailure("Could not create font provider")
				}
				
				font = provider.uiFont()
			}
		}
		
		return font
	}
}

private enum SwiftUIFontProvider {
	case system(size: CGFloat, weight: Font.Weight?, design: Font.Design?)
	case textStyle(Font.TextStyle, weight: Font.Weight?, design: Font.Design?)
	case platform(CTFont)
	case ready(UIFont)
	
	func uiFont() -> UIFont? {
		switch self {
		case let .system(size, weight, _):
			return weight?.toUIFontWeight().map { .systemFont(ofSize: size, weight: $0) } ?? .systemFont(ofSize: size)
		case let .textStyle(textStyle, _, _):
			return textStyle.toUIFontTextStyle().map(UIFont.preferredFont(forTextStyle:))
		case let .platform(font):
			return font as UIFont
		case let .ready(font):
			return font
		}
	}
	
	init?(from reflection: Any) {
		switch String(describing: type(of: reflection)) {
		case "SystemProvider":
			var props: (
				size: CGFloat?,
				weight: Font.Weight?,
				design: Font.Design?
			) = (nil, nil, nil)
			
			inspect(reflection) { label, value in
				switch label {
				case "size":
					props.size = value as? CGFloat
				case "weight":
					props.weight = value as? Font.Weight
				case "design":
					props.design = value as? Font.Design
				default:
					return
				}
			}
			
			guard let size = props.size
			else { return nil }
			
			self = .system(
				size: size,
				weight: props.weight,
				design: props.design
			)
			
		case "TextStyleProvider":
			var props: (
				style: Font.TextStyle?,
				weight: Font.Weight?,
				design: Font.Design?
			) = (nil, nil, nil)
			
			inspect(reflection) { label, value in
				switch label {
				case "style":
					props.style = value as? Font.TextStyle
				case "weight":
					props.weight = value as? Font.Weight
				case "design":
					props.design = value as? Font.Design
				default:
					return
				}
			}
			
			guard let style = props.style
			else { return nil }
			
			self = .textStyle(
				style,
				weight: props.weight,
				design: props.design
			)
			
		case "PlatformFontProvider":
			var font: CTFont?
			
			inspect(reflection) { label, value in
				guard label == "font" else { return }
				font = (value as? CTFont?)?.flatMap { $0 }
			}
			
			guard let font else { return nil }
			self = .platform(font)
			
		case "NamedProvider":
			var name: String? = nil
			var size: CGFloat? = nil
			var textStyle: SwiftUI.Font.TextStyle? = nil
			
			inspect(reflection) { label, value in
				switch label {
				case "name":
					name = value as? String
					break
				case "size":
					size = value as? CGFloat
					break
				case "textStyle":
					textStyle = value as? SwiftUI.Font.TextStyle
					break
				default:
					break
				}
			}
			
			guard let name, let size else { return nil }
			
			let font = UIFont(name: name, size: size)
			guard var font else { return nil }
			
			if let textStyle = textStyle?.toUIFontTextStyle() {
				font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
			}
			
			self = .ready(font)
			
		default:
			return nil
		}
	}
}

extension Font.TextStyle {
	fileprivate func toUIFontTextStyle() -> UIFont.TextStyle? {
		switch self {
		case .largeTitle:
			return .largeTitle
		case .title:
			return .title1
		case .headline:
			return .headline
		case .subheadline:
			return .subheadline
		case .body:
			return .body
		case .callout:
			return .callout
		case .footnote:
			return .footnote
		case .caption:
			return .caption1
		case .title2:
			return .title2
		case .title3:
			return .title3
		case .caption2:
			return .caption2
		default:
			assertionFailure()
			return .body
		}
	}
}

extension SwiftUI.Font.Weight {
	fileprivate func toUIFontWeight() -> UIFont.Weight? {
		var rawValue: CGFloat? = nil
		inspect(self) { label, value in
			guard label == "value" else { return }
			rawValue = value as? CGFloat
		}
		guard let rawValue else { return nil }
		return .init(rawValue)
	}
}

private func inspect(_ object: Any, with action: (Mirror.Child) -> Void) {
	Mirror(reflecting: object).children.forEach(action)
}
