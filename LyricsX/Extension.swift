//
//  BasicExtension.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/24.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import EasyPreference

extension UserDefaults {
    
    func reset() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
    
}

extension EasyPreference {
    
    var lyricsSavingPath: URL? {
        if self[LyricsSavingPathPopUpIndex] == 0 {
            return self[LyricsDefaultSavingPath].map() { URL(fileURLWithPath: $0) }
        } else {
            return lyricsCustomSavingPath
        }
    }
    
    var lyricsCustomSavingPath: URL? {
        get {
            guard let data = self[LyricsCustomSavingPathBookmark] else {
                return nil
            }
            var bookmarkDataIsStale = false
            do {
                let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], bookmarkDataIsStale: &bookmarkDataIsStale)
                return url
            } catch let error {
                print(error)
                return nil
            }
        }
        set {
            if let url = newValue,
                let data = try? url.bookmarkData(options: [.withSecurityScope]) {
                self[LyricsCustomSavingPathBookmark] = data
            }
        }
    }
    
}
