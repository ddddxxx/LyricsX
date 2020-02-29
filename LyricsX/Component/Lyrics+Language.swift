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
        let lyricsLanguageSet = NSCountedSet()
        let translationLanguageSet = NSCountedSet()
        for line in lines {
            if let lan = (line.content as NSString).dominantLanguage {
                lyricsLanguageSet.add(lan)
            }
            if let trans = line.attachments.translation(),
                let transLan = (trans as NSString).dominantLanguage {
                translationLanguageSet.add(transLan)
            }
        }
        if let lan = lyricsLanguageSet.mostFrequentElement as! String? {
            metadata.language = lan
        }
        if let transLan = translationLanguageSet.mostFrequentElement as! String? {
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
