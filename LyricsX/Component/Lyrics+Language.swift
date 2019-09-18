//
//  Lyrics+Language.swift
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
import LyricsCore

private extension NSCountedSet {
    
    var mostFrequentElement: Any? {
        var element: Any? = nil
        var count = 0
        for e in self {
            let c = self.count(for: e)
            if c > count {
                (element, count) = (e, c)
            }
        }
        return element
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
            for idx in lines.indices {
                if let trans = lines[idx].attachments[LyricsLine.Attachments.Tag.translation.rawValue] {
                    lines[idx].attachments[LyricsLine.Attachments.Tag.translation.rawValue] = nil
                    lines[idx].attachments.setTranslation(trans, languageCode: transLan)
                }
            }
            metadata.translationLanguages.append(transLan)
            metadata.attachmentTags.insert(tag)
        }
    }
}
