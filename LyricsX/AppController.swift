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
        if currentLyrics?.metadata[.source] as? String != "Local" {
            currentLyrics?.saveToLocal()
        }
    }
    
    // MARK: MediaPlayerDelegate
    
    func runningStateChanged(isRunning: Bool) {
        if Preference[LaunchAndQuitWithPlayer], !isRunning {
            NSApplication.shared().terminate(nil)
        }
    }
    
    func playerStateChanged(state: MusicPlayerState) {
        if state != .playing, Preference[DisableLyricsWhenPaused] {
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
        let title = track.name ?? ""    // TODO: ?
        let artist = track.artist ?? ""
        
        if let localLyrics = Lyrics.loadFromLocal(title: title, artist: artist) {
            setCurrentLyrics(lyrics: localLyrics)
        } else {
            lyricsManager.fetchLyrics(title: title, artist: artist)
        }
    }
    
    func playerPositionChanged(position: Double) {
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
        guard lyrics.metadata[.searchTitle] as? String == track?.name,
            lyrics.metadata[.searchArtist] as? String == track?.artist else {
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
            lrc.metadata = [
                .searchTitle: track.name ?? "", // TODO: ?
                .searchArtist: track.artist ?? "",
                .source: "Import"
            ]
            setCurrentLyrics(lyrics: lrc)
        }
    }
    
}
