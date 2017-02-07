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
        
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil, queue: .main) { self.handlePlayerInfoChange($0) }
    }
    
    func handlePlayerInfoChange (_ n:Notification) {
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
        
        print("song changed: \(currentSongName)")
    }
    
    func handlePositionChange() {
        print("position changed")
    }
    
}
