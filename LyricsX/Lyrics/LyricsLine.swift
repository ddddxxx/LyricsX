//
//  LyricsLine.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/22.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

struct LyricsLine {
    
    var sentence: String
    var translation: String?
    var position: Double
    var enabled: Bool
    
    var timeTag: String {
        let min = Int(position / 60)
        let sec = position - Double(min * 60)
        return String(format: "%02d:%06.3f", min, sec)
    }
    
    init(sentence: String, translation: String? = nil, position: Double) {
        self.sentence = sentence
        self.translation = translation
        self.position = position
        enabled = true
        normalization()
    }
    
    init?(sentence: String, translation: String? = nil, timeTag: String) {
        var tagContent = timeTag
        tagContent.remove(at: tagContent.startIndex)
        tagContent.remove(at: tagContent.index(before: tagContent.endIndex))
        let components = tagContent.components(separatedBy: ":")
        if components.count == 2,
            let min = Double(components[0]),
            let sec = Double(components[1]) {
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
    
    var hashValue: Int {
        return sentence.hashValue ^ position.hashValue ^ (translation?.hash ?? 0)
    }
    
    static func ==(lhs: LyricsLine, rhs: LyricsLine) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

extension LyricsLine {
    
    func contentString(withTimeTag: Bool, translation: Bool) -> String {
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
