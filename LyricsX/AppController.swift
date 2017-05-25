//
//  AppController.swift
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
import AppKit

class AppController: NSObject, MusicPlayerDelegate, LyricsConsuming {
    
    static let shared = AppController()
    
    let lyricsManager = LyricsSourceManager()
    
    private(set) var currentLyrics: Lyrics?
    dynamic var lyricsOffset: Int {
        get {
            return currentLyrics?.offset ?? 0
        }
        set {
            currentLyrics?.offset = newValue
            currentLyrics?.saveToLocal()
        }
    }
    
    private override init() {
        super.init()
        MusicPlayerManager.shared.delegate = self
        lyricsManager.consumer = self
        
        currentTrackChanged(track: MusicPlayerManager.shared.player?.currentTrack)
    }
    
    func setCurrentLyrics(lyrics: Lyrics?) {
        var lyrics = lyrics
        lyrics?.filtrate()
        willChangeValue(forKey: "lyricsOffset")
        currentLyrics = lyrics
        didChangeValue(forKey: "lyricsOffset")
        NotificationCenter.default.post(name: .LyricsChange, object: nil)
        if currentLyrics?.metadata.source != .Local {
            currentLyrics?.saveToLocal()
        }
        if lyrics == nil {
            NotificationCenter.default.post(name: .PositionChange, object: nil)
        }
    }
    
    // MARK: MediaPlayerDelegate
    
    func runningStateChanged(isRunning: Bool) {
        if defaults[.LaunchAndQuitWithPlayer], !isRunning {
            NSApplication.shared().terminate(nil)
        }
    }
    
    func playerStateChanged(state: MusicPlayerState) {
        if state != .playing, defaults[.DisableLyricsWhenPaused] {
            NotificationCenter.default.post(name: .PositionChange, object: nil)
        }
    }
    
    func currentTrackChanged(track: MusicTrack?) {
        setCurrentLyrics(lyrics: nil)
        let info = ["lrc": "", "next": ""]
        NotificationCenter.default.post(name: .PositionChange, object: nil, userInfo: info)
        guard let track = track else {
            return
        }
        let title = track.name
        let artist = track.artist
        
        guard !WrongLyricsUtil.shared.isNoMatching(title: title, artist: artist) else {
            return
        }
        
        if let localLyrics = Lyrics.loadFromLocal(title: title, artist: artist) {
            setCurrentLyrics(lyrics: localLyrics)
        } else {
            let duration = track.duration ?? 0
            lyricsManager.fetchLyrics(title: title, artist: artist, duration: duration)
        }
    }
    
    func playerPositionChanged(position: TimeInterval) {
        guard let lyrics = currentLyrics else {
            return
        }
        let lrc = lyrics[position]
        
        let info = [
            "lrc": lrc.current as Any,
            "next": lrc.next as Any,
            "position": position as Any,
        ]
        NotificationCenter.default.post(name: .PositionChange, object: nil, userInfo: info)
    }
    
    // MARK: LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        let track = MusicPlayerManager.shared.player?.currentTrack
        guard lyrics.metadata.title == track?.name,
            lyrics.metadata.artist == track?.artist else {
            return
        }
        
        if let current = currentLyrics, current >= lyrics {
            return
        }
        
        setCurrentLyrics(lyrics: lyrics)
    }
    
    func fetchCompleted(result: [Lyrics]) {
        
    }
}

extension AppController {
    
    func importLyrics(_ lyrics: String) {
        if var lrc = Lyrics(lyrics),
            let track = MusicPlayerManager.shared.player?.currentTrack {
            lrc.metadata.source = .Import
            lrc.metadata.title = track.name
            lrc.metadata.artist = track.artist
            setCurrentLyrics(lyrics: lrc)
        }
    }
}
