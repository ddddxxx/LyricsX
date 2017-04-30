//
//  AppController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/6.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
    }
    
    // MARK: MediaPlayerDelegate
    
    func runningStateChanged(isRunning: Bool) {
        if Preference[.LaunchAndQuitWithPlayer], !isRunning {
            NSApplication.shared().terminate(nil)
        }
    }
    
    func playerStateChanged(state: MusicPlayerState) {
        if state != .playing, Preference[.DisableLyricsWhenPaused] {
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
