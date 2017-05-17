//
//  WrongLyricsUtil.swift
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

class WrongLyricsUtil {
    
    static let shared = WrongLyricsUtil()
    
    var tracks: [[String: String]] = []
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(synchronize), name: .NSApplicationWillTerminate, object: nil)
        
        guard let (url, security) = defaults.lyricsSavingPath() else {
            return
        }
        if security {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
        }
        defer {
            if security {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let dictUrl = url.appendingPathComponent("NoMaching.plist")
        tracks = [String: Any](contentsOf: dictUrl)?["Tracks"] as? [[String: String]] ?? []
    }
    
    func isNoMatching(title: String, artist: String) -> Bool {
        return tracks.contains { $0["Title"] == title && $0["Artist"] == artist } == true
    }
    
    func noMatching(title: String, artist: String) {
        tracks.append(["Title": title, "Artist": artist])
    }
    
    @objc func synchronize() {
        guard let (url, security) = defaults.lyricsSavingPath() else {
            return
        }
        if security {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
        }
        defer {
            if security {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let dictUrl = url.appendingPathComponent("NoMaching.plist")
        let dict: [String: Any] = [
            "Version": 1,
            "Tracks": tracks
        ]
        try? dict.write(to: dictUrl)
    }
    
}
