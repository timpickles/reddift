//
//  NSAttributedString+reddift.swift
//  reddift
//
//  Created by sonson on 2015/10/18.
//  Copyright © 2015年 sonson. All rights reserved.
//

import Foundation

/// import to use NSFont/UIFont
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

/// Shared font and color class
#if os(iOS) || os(tvOS)
private typealias _Font = UIFont
private typealias _Color = UIColor
#elseif os(macOS)
private typealias _Font = NSFont
private typealias _Color = NSColor
#endif

/// Enum, attributes for NSAttributedString
private enum Attribute {
    case link(URL, Int, Int)
    case bold(Int, Int)
    case italic(Int, Int)
    case superscript(Int, Int)
    case strike(Int, Int)
    case code(Int, Int)
}

/// Extension for NSParagraphStyle
extension NSParagraphStyle {
    /**
    Returns default paragraph style for reddift framework.
    - parameter fontSize: Font size
    - returns: Paragraphyt style, which is created.
    */
    static func defaultReddiftParagraphStyle(with fontSize: CGFloat) -> NSParagraphStyle {
#if os(iOS) || os(tvOS)
        guard let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
                else { return NSParagraphStyle.default }
#elseif os(macOS)
        guard let paragraphStyle = NSParagraphStyle.default().mutableCopy() as? NSMutableParagraphStyle
                else { return NSParagraphStyle.default() }
#endif
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.maximumLineHeight = fontSize + 2
        paragraphStyle.minimumLineHeight = fontSize + 2
        paragraphStyle.lineSpacing = 1
        paragraphStyle.paragraphSpacing = 1
        paragraphStyle.paragraphSpacingBefore = 1
        paragraphStyle.lineHeightMultiple = 0
        return paragraphStyle
    }
}

/// shared regular expression
private let regexForHasImageFileExtension: NSRegularExpression! = {
    do {
        return try NSRegularExpression(pattern: "^/.+\\.(jpg|jpeg|gif|png)$", options: .caseInsensitive)
    } catch {
        assert(false, "Fatal error: \(#file) \(#line) - \(error)")
        return nil
    }
}()

/// Extension for NSAttributedString
extension String {
    /**
    Returns HTML string whose del and blockquote tag is replaced with font size tag in order to extract these tags using NSAttribtedString class method.
    
    - returns: String, which is processed.
    */
    public var preprocessedHTMLStringBeforeNSAttributedStringParsing: String {
        get {
            var temp = self.replacingOccurrences(of: "<del>", with: "<font size=\"5\">")
            temp = temp.replacingOccurrences(of: "<blockquote>", with: "<cite>")
            temp = temp.replacingOccurrences(of: "</blockquote>", with: "</cite>")
            return temp.replacingOccurrences(of: "</del>", with: "</font>")
        }
    }
}

/// Extension for NSAttributedString.includedImageURL
extension URLComponents {

    /// Returns true when URL's filename has image's file extension(such as gif, jpg, png).
    public var hasImageFileExtension: Bool {
        let path = self.path
        if let r = regexForHasImageFileExtension.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.characters.count)) {
            return r.range(at: 1).length > 0
        }
        return false
    }
}