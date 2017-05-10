//
//  WrongLyricsUtil.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/5/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
