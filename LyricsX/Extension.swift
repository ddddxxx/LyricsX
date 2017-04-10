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
    
    func lyricsSavingPath(securityScoped: inout Bool) -> URL? {
        if self[LyricsSavingPathPopUpIndex] == 0 {
            securityScoped = false
            let userPath = String(cString: getpwuid(getuid()).pointee.pw_dir)
            return URL(fileURLWithPath: userPath).appendingPathComponent("Music/LyricsX")
        } else {
            securityScoped = true
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

extension Lyrics {
    
    var fileName: String {
        let title = (metadata[.searchTitle] as? String)?.replacingOccurrences(of: "/", with: "&") ?? ""
        let artist = (metadata[.searchArtist] as? String)?.replacingOccurrences(of: "/", with: "&") ?? ""
        return "\(title) - \(artist).lrc"
    }
    
}
