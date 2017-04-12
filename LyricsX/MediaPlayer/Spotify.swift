//
//  Spotify.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class Spotify: MusicPlayer {
    
    var isRunning: Bool {
        return (_spotify as! SBApplication).isRunning
    }
    
    var currentTrack: MusicTrack? {
        return _spotify.currentTrack?.track
    }
    
    var playerState: MusicPlayerState {
        return _spotify.playerState?.state ?? .stopped
    }
    
    var playerPosition: Double {
        get {
            return _spotify.playerPosition ?? 0
        }
        set {
            (_spotify as! SBApplication).setValue(newValue, forKey: "playerPosition")
        }
    }
    
    private var _spotify: SpotifyApplication
    
    init?() {
        guard let spotify = SBApplication(bundleIdentifier: "com.spotify.client") else {
            return nil
        }
        _spotify = spotify
    }
    
}

// MARK - Spotify Bridge Extension

extension SpotifyEPlS {
    var state: MusicPlayerState {
        switch self {
        case .SpotifyEPlSStopped:
            return .stopped
        case .SpotifyEPlSPlaying:
            return .playing
        case .SpotifyEPlSPaused:
            return .paused
        }
    }
}

extension SpotifyTrack {
    var track: MusicTrack? {
        guard let id = id?() as String? else {
            return nil
        }
        
        return MusicTrack(id: id, name: name as String?, album: album as String?, artist: artist as String?)
    }
}
