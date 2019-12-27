//
//  StdExtension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

extension Comparable {
    
    func clamped(to limit: ClosedRange<Self>) -> Self {
        return min(max(self, limit.lowerBound), limit.upperBound)
    }
    
    func clamped(to limit: PartialRangeThrough<Self>) -> Self {
        return min(self, limit.upperBound)
    }
    
    func clamped(to limit: PartialRangeFrom<Self>) -> Self {
        return max(self, limit.lowerBound)
    }
}

extension Strideable {
    
    func clamped(to limit: Range<Self>) -> Self {
        guard !limit.isEmpty else {
            preconditionFailure("Range cannot be empty")
        }
        let upperBound = limit.upperBound.advanced(by: -1)
        return min(max(self, limit.lowerBound), upperBound)
    }
    
    func clamped(to limit: PartialRangeUpTo<Self>) -> Self {
        let upperBound = limit.upperBound.advanced(by: -1)
        return min(self, upperBound)
    }
}

// MARK: - Range

extension NSString {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}

extension String {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
}

extension NSAttributedString {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}

extension CharacterSet {
    
    static let hiragana = CharacterSet(charactersIn: "\u{3040}"..<"\u{30a0}")
    static let katakana = CharacterSet(charactersIn: "\u{30a0}"..<"\u{3100}")
    static let kana = CharacterSet(charactersIn: "\u{3040}"..<"\u{3100}")
    static let kanji = CharacterSet(charactersIn: "\u{4e00}"..<"\u{9fc0}")
}
