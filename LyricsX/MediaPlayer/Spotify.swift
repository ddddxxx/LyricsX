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
        guard isRunning else { return nil }
        return _spotify.currentTrack?.track
    }
    
    var playerState: MusicPlayerState {
        guard isRunning else { return .stopped }
        return _spotify.playerState?.state ?? .stopped
    }
    
    var playerPosition: Double {
        get {
            guard isRunning else { return 0 }
            return _spotify.playerPosition ?? 0
        }
        set {
            guard isRunning else { return }
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
