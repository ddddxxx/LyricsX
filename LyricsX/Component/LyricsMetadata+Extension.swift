//
//  LyricsMetadata+Extension.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore

extension Lyrics.Metadata.Key {
    static var localURL = Lyrics.Metadata.Key("localURL")
    static var title = Lyrics.Metadata.Key("title")
    static var artist = Lyrics.Metadata.Key("artist")
    static var needsPersist = Lyrics.Metadata.Key("needsPersist")
    static var language = Lyrics.Metadata.Key("language")
}

extension Lyrics.Metadata {
    
    var localURL: URL? {
        get { return data[.localURL] as? URL }
        set { data[.localURL] = newValue }
    }
    
    var title: String? {
        get { return data[.title] as? String }
        set { data[.title] = newValue }
    }
    
    var artist: String? {
        get { return data[.artist] as? String }
        set { data[.artist] = newValue }
    }
    
    var needsPersist: Bool {
        get { return data[.needsPersist] as? Bool ?? false }
        set { data[.needsPersist] = newValue }
    }
    
    var language: String? {
        get { return data[.language] as? String }
        set { data[.language] = newValue }
    }
    
    var translationLanguages: [String] {
        return attachmentTags.compactMap { $0.translationLanguageCode }
    }
}

private extension LyricsLine.Attachments.Tag {
    var translationLanguageCode: String? {
        guard rawValue.hasPrefix("tr:") else {
            return nil
        }
        let code = rawValue.dropFirst(3)
        return code.isEmpty ? nil : String(code)
    }
}
