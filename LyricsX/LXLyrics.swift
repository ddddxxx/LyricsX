//
//  LXLyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

struct LXLyricsLine {
    
    var sentence: String
    var position: Double
    
    init(sentence: String, position: Double) {
        self.sentence = sentence
        self.position = position
    }
    
    init?(sentence: String, timeTag: String) {
        var tagContent = timeTag
        tagContent.remove(at: tagContent.startIndex)
        tagContent.remove(at: tagContent.index(before: tagContent.endIndex))
        let components = tagContent.components(separatedBy: ":")
        if components.count == 2,
            let min = Double(components[0]),
            let sec = Double(components[1]) {
            let position = sec + min * 60
            self.init(sentence: sentence, position: position)
        } else {
            return nil
        }
    }
    
    init?(line: String) {
        guard let regexForTimeTag = try? NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]") else {
            return nil
        }
        guard let matched = regexForTimeTag.firstMatch(in: line, range: NSMakeRange(0, line.characters.count)) else {
            return nil
        }
        let timeTag = (line as NSString).substring(with: matched.range)
        let sentence = (line as NSString).substring(from: matched.range.location + matched.range.length)
        self.init(sentence: sentence, timeTag: timeTag)
    }
    
}

struct LXLyrics {
    
    var lyrics: [LXLyricsLine]
    var idTags: [String: String]
    var metaData: [String: Any]
    
    var offset: Int {
        get {
            return idTags["offset"].flatMap() { Int($0) } ?? 0
        }
        set {
            idTags["offset"] = "\(offset)"
        }
    }
    var timeDelay: Double {
        get {
            return Double(offset) / 1000
        }
        set {
            offset = Int(timeDelay * 1000)
        }
    }
    
    init?(_ lrcContents: String) {
        lyrics = []
        idTags = [:]
        metaData = [:]
        
        guard let regexForIDTag = try? NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]") else {
            return
        }
        
        let lyricsLines = lrcContents.components(separatedBy: .newlines)
        for line in lyricsLines {
            if let lyric = LXLyricsLine(line: line) {
                lyrics += [lyric]
            } else {
                let idTagsMatched = regexForIDTag.matches(in: line, range: NSMakeRange(0, line.characters.count))
                guard idTagsMatched.count > 0 else {
                    continue
                }
                for result in idTagsMatched {
                    var tagStr = ((line as NSString).substring(with: result.range)) as String
                    tagStr.remove(at: tagStr.startIndex)
                    tagStr.remove(at: tagStr.index(before: tagStr.endIndex))
                    let components = tagStr.components(separatedBy: ":")
                    if components.count == 2 {
                        let key = components[0]
                        let value = components[1]
                        idTags[key] = value
                    }
                }
            }
        }
        
        if lyricsLines.count == 0 {
            return nil
        }
        
        lyrics.sort() { $0.position < $1.position }
    }
    
    subscript(at position: Double) -> (current:LXLyricsLine?, next:LXLyricsLine?) {
        for (index, line) in lyrics.enumerated() {
            if line.position > position {
                let previous = lyrics.index(index, offsetBy: -1, limitedBy: lyrics.startIndex).flatMap() { lyrics[$0] }
                return (previous, line)
            }
        }
        return (lyrics.last, nil)
    }
    
}

extension LXLyricsLine: CustomStringConvertible {
    public var description: String {
        get {
            return "[\(position)]\(sentence)"
        }
    }
}

extension LXLyrics: CustomStringConvertible {
    public var description: String {
        get {
            let tag = idTags.reduce("") { $0 + "[\($1.key): \($1.value)]\n" }
            let lrc = lyrics.reduce("") { $0 + "\($1.description)\n" }
            return tag + lrc
        }
    }
}
