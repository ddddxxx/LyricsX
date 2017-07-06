//
//  LyricsLine.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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

public struct LyricsLine {
    
    public var sentence: String
    public var translation: String?
    public var position: TimeInterval
    public var enabled: Bool
    
    public var timeTag: String {
        let min = Int(position / 60)
        let sec = position - TimeInterval(min * 60)
        return String(format: "%02d:%06.3f", min, sec)
    }
    
    public init(sentence: String, translation: String? = nil, position: TimeInterval) {
        self.sentence = sentence
        self.translation = translation
        self.position = position
        enabled = true
        normalization()
    }
    
    public init?(sentence: String, translation: String? = nil, timeTag: String) {
        var tagContent = timeTag
        tagContent.remove(at: tagContent.startIndex)
        tagContent.remove(at: tagContent.index(before: tagContent.endIndex))
        let components = tagContent.components(separatedBy: ":")
        if components.count == 2,
            let min = TimeInterval(components[0]),
            let sec = TimeInterval(components[1]) {
            let position = sec + min * 60
            self.init(sentence: sentence, translation: translation, position: position)
        } else {
            return nil
        }
    }
    
    private static let serialWhiteSpacesRegex = try! NSRegularExpression(pattern: "( )+")
    
    private mutating func normalization() {
        sentence = sentence.trimmingCharacters(in: .whitespaces)
        sentence = LyricsLine.serialWhiteSpacesRegex.stringByReplacingMatches(in: sentence, options: [], range: sentence.range, withTemplate: " ")
        if sentence == "." {
            sentence = ""
        }
    }
}

extension LyricsLine: Equatable, Hashable {
    
    public var hashValue: Int {
        return sentence.hashValue ^ position.hashValue ^ (translation?.hash ?? 0)
    }
    
    public static func ==(lhs: LyricsLine, rhs: LyricsLine) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension LyricsLine {
    
    public func contentString(withTimeTag: Bool, translation: Bool) -> String {
        var content = ""
        if withTimeTag {
            content += "[" + timeTag + "]"
        }
        content += sentence
        if translation, let transStr = self.translation {
            content += "【" + transStr + "】"
        }
        return content
    }
}

extension LyricsLine: CustomStringConvertible {
    
    public var description: String {
        return contentString(withTimeTag: true, translation: true)
    }
}

extension String {
    
    var range: NSRange {
        return NSRange(location: 0, length: characters.count)
    }
}
