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
    
    static let shared = iTunesHelper()
    
    var iTunes: iTunesApplication!
    
    var positionChangeTimer: Timer!
    
    var currentSongID: Int?
    var currentSongName: String?
    var currentArtist: String?
    var currentLyrics: LXLyrics?
    
    private init() {
        iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes")
        
        positionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in self.handlePositionChange() }
        
        NotificationCenter.default.addObserver(forName: .lyricsLoaded, object: nil, queue: nil) { self.handleLyricsLoad($0) }
        
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
        currentSongName = track?.name as String?
        currentArtist = track?.artist as String?
        currentLyrics = nil
        
        print("song changed: \(currentSongName)")
        
        guard let id = currentSongID, let name = currentSongName, let artist = currentArtist else {
            return
        }
        
        LyricsXiami().searchLrcFor(title: name, artist: artist, iTunesID: id)
    }
    
    func handlePositionChange() {
        guard let lyrics = currentLyrics, let position = iTunes.playerPosition else {
            return
        }
        
        var currentLrcSentence = ""
        var nextLrcSentence = ""
        
        for (index, line) in lyrics.lyrics.enumerated() {
            if line.position > position {
                let previous = index==0 ? 0 : index-1
                currentLrcSentence = lyrics.lyrics[previous].sentence
                nextLrcSentence = lyrics.lyrics[index].sentence
                break
            }
        }
        let info = ["lrc": currentLrcSentence, "next": nextLrcSentence]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
    }
    
    func handleLyricsLoad(_ n:Notification) {
        guard currentLyrics == nil else {
            return
        }
        guard let info = n.userInfo, let lrcURL = info["lrcURL"] as? URL else {
            return
        }
        
        if let lrcContent = try? String(contentsOf: lrcURL) {
            guard let lrc = LXLyrics(lrcContent) else {
                return
            }
            currentLyrics = lrc
            print(lrc)
        }
    }
    
}
