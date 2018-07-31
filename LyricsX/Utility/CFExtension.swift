//
//  CFExtension.swift
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

import Foundation

// MARK: - CFStringTokenizer

extension NSString {
    
    var dominantLanguage: String? {
        let cfStr = self as CFString
        return CFStringTokenizerCopyBestStringLanguage(cfStr, cfStr.fullRange) as String?
    }
}

extension CFStringTokenizer {
    
    struct Attribute: RawRepresentable {
        
        var rawValue: CFOptionFlags
        
        init(rawValue: CFOptionFlags) {
            self.rawValue = rawValue
        }
        
        static let latinTranscription = Attribute(rawValue: kCFStringTokenizerAttributeLatinTranscription)
        static let language = Attribute(rawValue: kCFStringTokenizerAttributeLanguage)
    }
    
    struct Unit: RawRepresentable {
        
        var rawValue: CFOptionFlags
        
        init(rawValue: CFOptionFlags) {
            self.rawValue = rawValue
        }
        
        static let word = Unit(rawValue: kCFStringTokenizerUnitWord)
        static let sentence = Unit(rawValue: kCFStringTokenizerUnitSentence)
        static let paragraph = Unit(rawValue: kCFStringTokenizerUnitParagraph)
        static let lineBreak = Unit(rawValue: kCFStringTokenizerUnitLineBreak)
        static let wordBoundary = Unit(rawValue: kCFStringTokenizerUnitWordBoundary)
    }
    
    static func create(_ string: NSString, range: NSRange? = nil, unit: Unit = .wordBoundary, locale: NSLocale? = nil) -> CFStringTokenizer {
        let cfStr = string as CFString
        return CFStringTokenizerCreate(nil, cfStr, range?.asCF ?? cfStr.fullRange, unit.rawValue, locale as CFLocale?)
    }
    
    func nextToken() -> CFStringTokenizerTokenType? {
        let token = CFStringTokenizerAdvanceToNextToken(self)
        if token.isEmpty { return nil }
        return token
    }
    
    func token(at index: CFIndex) -> CFStringTokenizerTokenType? {
        let token = CFStringTokenizerGoToTokenAtIndex(self, index)
        if token.isEmpty { return nil }
        return token
    }
    
    func currentTokenRange() -> NSRange {
        return CFStringTokenizerGetCurrentTokenRange(self).asNS
    }
    
    func currentTokenAttribute(_ attribute: Attribute) -> NSString? {
        // swiftlint:disable:next force_cast
        return CFStringTokenizerCopyCurrentTokenAttribute(self, attribute.rawValue) as! NSString?
    }
    
    func currentSubTokens() -> [CFStringTokenizerTokenType] {
        let arr = NSMutableArray()
        CFStringTokenizerGetCurrentSubTokens(self, nil, 0, arr as CFMutableArray)
        // swiftlint:disable:next force_cast
        return arr as! [CFStringTokenizerTokenType]
    }
}

extension CFStringTokenizer: IteratorProtocol, Sequence {
    
    public func next() -> CFStringTokenizerTokenType? {
        return nextToken()
    }
}
