//
//  Lyrics+Language.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import LyricsCore

private extension NSCountedSet {
    
    var mostFrequentElement: Any? {
        var result: (Any?, Int) = (nil, 0)
        for element in self {
            let count = self.count(for: element)
            if count > result.1 {
                result = (element, count)
            }
        }
        return result.0
    }
}

extension Lyrics {
    
    func recognizeLanguage() {
        var lyricsContent = ""
        var translationContent = ""
        for line in lines {
            lyricsContent += line.content
            if let trans = line.attachments.translation() {
                translationContent += trans
            }
        }
        metadata.language = (lyricsContent as NSString).dominantLanguage
        if let transLan = (translationContent as NSString).dominantLanguage {
            let tag = LyricsLine.Attachments.Tag.translation(languageCode: transLan)
            guard !metadata.attachmentTags.contains(tag) else {
                return
            }
            for idx in lines.indices {
                if let trans = lines[idx].attachments[LyricsLine.Attachments.Tag.translation.rawValue] {
                    lines[idx].attachments[LyricsLine.Attachments.Tag.translation.rawValue] = nil
                    lines[idx].attachments.setTranslation(trans, languageCode: transLan)
                }
            }
            metadata.attachmentTags.insert(tag)
        }
    }
}
