//
//  CTExtension.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreText
import Foundation

// MARK: - CTRubyAnnotation

extension NSAttributedStringKey {
    
    static let rubyAnnotation = kCTRubyAnnotationAttributeName as NSAttributedStringKey
    
    /// kCTRubyAnnotationSizeFactorAttributeName
    static let rubyAnnotationSizeFactor = NSAttributedStringKey("CTRubyAnnotationSizeFactor")
}

extension CTRubyAnnotation {
    
    static func create(_ string: NSString,
                       position: CTRubyPosition = .before,
                       alignment: CTRubyAlignment = .auto,
                       overhang: CTRubyOverhang = .auto,
                       attributes: [NSAttributedStringKey: Any] = [:]) -> CTRubyAnnotation {
        if #available(OSX 10.12, *) {
            return CTRubyAnnotationCreateWithAttributes(alignment, overhang, position, string as CFString, attributes as CFDictionary)
        } else {
            let string = NSString(string: string)
            let count = Int(CTRubyPosition.count.rawValue)
            let text = UnsafeMutablePointer<Unmanaged<CFString>?>.allocate(capacity: count)
            let sizeFactor = attributes[.rubyAnnotationSizeFactor] as? NSNumber as? CGFloat ?? 0.5
            defer { text.deallocate() }
            text.initialize(repeating: nil, count: count)
            let pos = Int(position.rawValue).clamped(to: 0..<count)
            text[pos] = Unmanaged.passUnretained(string)
            return CTRubyAnnotationCreate(alignment, overhang, sizeFactor, text)
        }
    }
}

// MARK: - CTFrame

extension CTFrame {
    
    var lines: [CTLine] {
        // swiftlint:disable:next force_cast
        return CTFrameGetLines(self) as! [CTLine]
    }
    
    var lineOrigins: [CGPoint] {
        let lineCount = lines.count
        let range = CFRange(location: 0, length: lineCount)
        var arr = [CGPoint](repeating: .zero, count: lineCount)
        CTFrameGetLineOrigins(self, range, &arr)
        return arr
    }
    
    var lineAndOrigins: Zip2Sequence<[CTLine], [CGPoint]> {
        let lines = self.lines
        let lineCount = lines.count
        let range = CFRange(location: 0, length: lineCount)
        var arr = [CGPoint](repeating: .zero, count: lineCount)
        CTFrameGetLineOrigins(self, range, &arr)
        return zip(lines, arr)
    }
}

// MARK: - CTLine

extension CTLine {
    
    var glyphCount: CFIndex {
        return CTLineGetGlyphCount(self)
    }
    
    var glyphRuns: [CTRun] {
        // swiftlint:disable:next force_cast
        return CTLineGetGlyphRuns(self) as! [CTRun]
    }
    
    var stringRange: NSRange {
        return CTLineGetStringRange(self).asNS
    }
    
    var trailingWhitespaceWidth: Double {
        return CTLineGetTrailingWhitespaceWidth(self)
    }
    
    func bounds(options: CTLineBoundsOptions = []) -> CGRect {
        return CTLineGetBoundsWithOptions(self, options)
    }
    
    func imageBounds(context: CGContext) -> CGRect {
        return CTLineGetImageBounds(self, context)
    }
    
    func offset(charIndex: CFIndex) -> CGFloat {
        return CTLineGetOffsetForStringIndex(self, charIndex, nil)
    }
    
    func enumerateCaretOffsets(_ block: (_ offset: Double, _ charIndex: CFIndex, _ leadingEdge: Bool, _ stop: UnsafeMutablePointer<Bool>) -> Void) {
        withoutActuallyEscaping(block) { block in
            CTLineEnumerateCaretOffsets(self, block)
        }
    }
}
