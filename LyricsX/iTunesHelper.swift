//
//  iTunesHelper.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/6.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class iTunesHelper {
    
    var iTunes: iTunesApplication!
    var lyricsHelper: LyricsSourceHelper
    
    var positionChangeTimer: Timer!
    
    var currentSongID: Int?
    var currentSongTitle: String?
    var currentArtist: String?
    var currentLyrics: LXLyrics?
    
    var currentLyricsLine: LXLyricsLine?
    var nextLyricsLine: LXLyricsLine?
    
    var fetchLrcQueue = OperationQueue()
    
    init() {
        iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes")
        lyricsHelper = LyricsSourceHelper()
        
        positionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in self.handlePositionChange() }
        
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil, queue: nil) { notification in self.handlePlayerInfoChange() }
        
        handlePlayerInfoChange()
    }
    
    func handlePlayerInfoChange () {
        let id = iTunes.currentTrack?.id?()
        if currentSongID != id {
            handleSongChange()
        }
        
        if let state = iTunes.playerState {
            switch state {
            case .iTunesEPlSPlaying:
                positionChangeTimer.fireDate = Date()
                print("playing")
            case .iTunesEPlSPaused, .iTunesEPlSStopped:
                positionChangeTimer.fireDate = .distantFuture
                print("Paused")
            default:
                break
            }
        }
    }
    
    func handleSongChange() {
        let track = iTunes.currentTrack
        currentSongID = track?.id?()
        currentSongTitle = track?.name as String?
        currentArtist = track?.artist as String?
        currentLyrics = nil
        
        print("song changed: \(currentSongTitle)")
        
        let info = ["lrc": "", "next": ""]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
        
        guard let title = currentSongTitle, let artist = currentArtist else {
            return
        }
        
        if let localLyrics = lyricsHelper.readLocalLyrics(title: title, artist: artist) {
            currentLyrics = localLyrics
        } else {
            lyricsHelper.fetchLyrics(title: title, artist: artist) {
                self.currentLyrics = self.lyricsHelper.lyrics.first
                self.currentLyrics?.saveToLocal()
            }
        }
    }
    
    func handlePositionChange() {
        guard let lyrics = currentLyrics, let position = iTunes.playerPosition else {
            return
        }
        
        let lrc = lyrics[position]
        
        if currentLyricsLine == lrc.current {
            return
        }
        
        currentLyricsLine = lrc.current
        nextLyricsLine = lrc.next
        
        let info = [
            "lrc": currentLyricsLine?.sentence as Any,
            "next": nextLyricsLine?.sentence as Any
        ]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
    }
    
}
