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
    var lyricsSource: [LyricsSource]
    
    var positionChangeTimer: Timer!
    
    var currentSongID: Int?
    var currentSongName: String?
    var currentArtist: String?
    var currentLyrics: LXLyrics?
    
    var fetchLrcQueue = OperationQueue()
    
    init() {
        iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes")
        lyricsSource = [LyricsXiami()]
        
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
        currentSongName = track?.name as String?
        currentArtist = track?.artist as String?
        currentLyrics = nil
        
        print("song changed: \(currentSongName)")
        
        let info = ["lrc": "", "next": ""]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
        
        guard let name = currentSongName, let artist = currentArtist else {
            return
        }
        
        fetchLrcQueue.cancelAllOperations()
        
        // TODO: fetch all source and sort
        fetchLrcQueue.addOperation {
            self.currentLyrics = self.lyricsSource.first?.fetchLyrics(title: name, artist: artist).first
            print(self.currentLyrics ?? "no lrc")
        }
    }
    
    func handlePositionChange() {
        guard let lyrics = currentLyrics, let position = iTunes.playerPosition else {
            return
        }
        
        let lrc = lyrics[at: position]
        
        let currentLrcSentence = lrc.current?.sentence ?? ""
        let nextLrcSentence = lrc.next?.sentence ?? ""
        
        let info = ["lrc": currentLrcSentence, "next": nextLrcSentence]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
    }
    
}

protocol LyricsSource {
    
    func fetchLyrics(title: String, artist: String) -> [LXLyrics]
    
}
