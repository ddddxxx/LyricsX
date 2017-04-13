//
//  Lyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

struct Lyrics {
    
    var lyrics: [LyricsLine]
    var idTags: [IDTagKey: String]
    var metadata: [MetadataKey: Any]
    
    var offset: Int {
        get {
            return idTags[.offset].flatMap() { Int($0) } ?? 0
        }
        set {
            idTags[.offset] = "\(newValue)"
        }
    }
    
    var timeDelay: TimeInterval {
        get {
            return TimeInterval(offset) / 1000
        }
        set {
            offset = Int(newValue * 1000)
        }
    }
    
    private static let idTagRegex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]")
    private static let timeTagRegex = try! NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]")
    
    init?(_ lrcContents: String) {
        lyrics = []
        idTags = [:]
        metadata = [:]
        
        let lyricsLines = lrcContents.components(separatedBy: .newlines)
        for line in lyricsLines {
            let timeTagsMatched = Lyrics.timeTagRegex.matches(in: line, options: [], range: line.range)
            if timeTagsMatched.count > 0 {
                let index: Int = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
                let lyricsSentence: String = line.substring(from: line.characters.index(line.startIndex, offsetBy: index))
                let components = lyricsSentence.components(separatedBy: "【")
                let lyricsStr: String
                let translation: String?
                if components.count == 2, components[1].characters.last == "】" {
                    lyricsStr = components[0]
                    translation = String(components[1].characters.dropLast())
                } else {
                    lyricsStr = lyricsSentence
                    translation = nil
                }
                let lyrics = timeTagsMatched.flatMap() { result -> LyricsLine? in
                    let timeTagStr = (line as NSString).substring(with: result.range) as String
                    return LyricsLine(sentence: lyricsStr, translation: translation, timeTag: timeTagStr)
                }
                self.lyrics += lyrics
            } else {
                let idTagsMatched = Lyrics.idTagRegex.matches(in: line, range: line.range)
                guard idTagsMatched.count > 0 else {
                    continue
                }
                for result in idTagsMatched {
                    var tagStr = ((line as NSString).substring(with: result.range)) as String
                    tagStr.remove(at: tagStr.startIndex)
                    tagStr.remove(at: tagStr.index(before: tagStr.endIndex))
                    let components = tagStr.components(separatedBy: ":")
                    if components.count == 2 {
                        let key = IDTagKey(components[0])
                        let value = components[1]
                        idTags[key] = value
                    }
                }
            }
        }
        
        if lyrics.count == 0 {
            return nil
        }
        
        lyrics.sort() { $0.position < $1.position }
    }
    
    init?(metadata: [MetadataKey: Any]) {
        guard let lrcURL = metadata[.lyricsURL] as? URL,
            let lrcContent = try? String(contentsOf: lrcURL) else {
            return nil
        }
        
        self.init(lrcContent)
        self.metadata = metadata
    }
    
    subscript(_ position: TimeInterval) -> (current:LyricsLine?, next:LyricsLine?) {
        let lyrics = self.lyrics.filter() { $0.enabled }
        guard let index = lyrics.index(where: { $0.position - timeDelay > position }) else {
            return (lyrics.last, nil)
        }
        let previous = lyrics.index(index, offsetBy: -1, limitedBy: lyrics.startIndex).flatMap() { lyrics[$0] }
        return (previous, lyrics[index])
    }
}

extension Lyrics {
    
    struct IDTagKey: RawRepresentable, Hashable {
        
        var rawValue: String
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        var hashValue: Int {
            return rawValue.hash
        }
        
        static let title    = IDTagKey("ti")
        static let album    = IDTagKey("al")
        static let artist   = IDTagKey("ar")
        static let author   = IDTagKey("au")
        static let lrcBy    = IDTagKey("by")
        static let offset   = IDTagKey("offset")
    }
    
    enum MetadataKey: String {
        case source             = "source"
        case lyricsURL          = "lyricsURL"
        case searchTitle        = "searchTitle"
        case searchArtist       = "searchArtist"
        case searchIndex        = "searchIndex"
        case artworkURL         = "artworkURL"
        case includeTranslation = "includeTranslation"
    }
}

extension Lyrics {
    
    func contentString(withMetadata: Bool, ID3: Bool, timeTag: Bool, translation: Bool) -> String {
        var content = ""
        if withMetadata {
            content += metadata.map {
                return "[\($0.key):\($0.value)]\n"
            }.joined()
        }
        if ID3 {
            content += idTags.map() {
                return "[\($0.key.rawValue):\($0.value)]\n"
            }.joined()
        }
        
        content += lyrics.map() {
            return $0.contentString(withTimeTag: timeTag, translation: translation) + "\n"
        }.joined()
        
        return content
    }
}

extension Lyrics {
    
    mutating func filtrate(using regex: NSRegularExpression) {
        for (index, lyric) in lyrics.enumerated() {
            let sentence = lyric.sentence.replacingOccurrences(of: " ", with: "")
            let numberOfMatches = regex.numberOfMatches(in: sentence, options: [], range: sentence.range)
            if numberOfMatches > 0 {
                lyrics[index].enabled = false
                continue
            }
        }
    }
    
    mutating func smartFiltrate() {
        for (index, lyric) in lyrics.enumerated() {
            let sentence = lyric.sentence
            if let idTagTitle = idTags[.title],
                let idTagArtist = idTags[.artist],
                sentence.contains(idTagTitle),
                sentence.contains(idTagArtist) {
                lyrics[index].enabled = false
            } else if let iTunesTitle = metadata[.searchTitle] as? String,
                let iTunesArtist = metadata[.searchArtist] as? String,
                sentence.contains(iTunesTitle),
                sentence.contains(iTunesArtist) {
                lyrics[index].enabled = false
            }
        }
    }
}

infix operator ?>
private func ?>(lhs: Bool?, rhs: Bool?) -> Bool? {
    switch (lhs, rhs) {
    case (.some(true), .some(true)), (.some(false), .some(false)):
        return nil
    case (.some(true), _), (_, .some(false)):
        return true
    case (_, .some(true)), (.some(false), _):
        return false
    default:
        return nil
    }
}

extension Lyrics {
    
    static func >(lhs: Lyrics, rhs: Lyrics) -> Bool {
        if lhs.metadata[.source] as? String == rhs.metadata[.source] as? String,
            let lIndex = lhs.metadata[.searchIndex] as? Int,
            let rIndex = rhs.metadata[.searchIndex] as? Int {
            return lIndex < rIndex
        }
        
        if let artistComparison = lhs.isFitArtist ?> rhs.isFitArtist {
            return artistComparison
        }
        
        if let artistComparison = lhs.isApproachArtise ?> rhs.isApproachArtise {
            return artistComparison
        }
        
        if let titleComparison = lhs.isFitTitle ?> rhs.isFitTitle {
            return titleComparison
        }
        
        if let titleComparison = lhs.isApproachTitle ?> rhs.isApproachTitle {
            return titleComparison
        }
        
        if let translationComparison = (lhs.metadata[.includeTranslation] as? Bool) ?> (rhs.metadata[.includeTranslation] as? Bool) {
            return translationComparison
        }
        
        return false
    }
    
    static func <(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return rhs > lhs
    }
    
    static func >=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs < rhs)
    }
    
    static func <=(lhs: Lyrics, rhs: Lyrics) -> Bool {
        return !(lhs > rhs)
    }
    
    private var isFitArtist: Bool? {
        guard let searchArtist = metadata[.searchArtist] as? String,
            let artist = idTags[.artist] else {
            return nil
        }
        
        return searchArtist == artist
    }
    
    private var isApproachArtise: Bool? {
        guard let searchArtist = metadata[.searchArtist] as? String,
            let artist = idTags[.artist] else {
                return nil
        }
        
        let s1 = searchArtist.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = artist.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
    
    private var isFitTitle: Bool? {
        guard let searchTitle = metadata[.searchTitle] as? String,
            let title = idTags[.title] else {
                return nil
        }
        
        return searchTitle == title
    }
    
    private var isApproachTitle: Bool? {
        guard let searchTitle = metadata[.searchTitle] as? String,
            let title = idTags[.title] else {
                return nil
        }
        
        let s1 = searchTitle.lowercased().replacingOccurrences(of: " ", with: "")
        let s2 = title.lowercased().replacingOccurrences(of: " ", with: "")
        
        return s1.contains(s2) || s2.contains(s1)
    }
}

extension Lyrics.IDTagKey: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

extension Lyrics: CustomStringConvertible {
    
    public var description: String {
        return contentString(withMetadata: true, ID3: true, timeTag: true, translation: true)
    }
}
