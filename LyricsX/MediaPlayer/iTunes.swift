//
//  iTunes.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class iTunes: MusicPlayer {
    
    var isRunning: Bool {
        return (_iTunes as! SBApplication).isRunning
    }
    
    var currentTrack: MusicTrack? {
        return _iTunes.currentTrack?.track
    }
    
    var playerState: MusicPlayerState {
        return _iTunes.playerState?.state ?? .stopped
    }
    
    var playerPosition: Double {
        get {
            return _iTunes.playerPosition ?? 0
        }
        set {
            (_iTunes as! SBApplication).setValue(newValue, forKey: "playerPosition")
        }
    }
    
    private var _iTunes: iTunesApplication
    
    init?() {
        guard let iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes") else {
            return nil
        }
        self._iTunes = iTunes
    }
    
}

// MARK - iTunes Bridge Extension

extension iTunesEPlS {
    var state: MusicPlayerState {
        switch self {
        case .iTunesEPlSStopped:
            return .stopped
        case .iTunesEPlSPlaying:
            return .playing
        case .iTunesEPlSPaused:
            return .paused
        case .iTunesEPlSFastForwarding:
            return .fastForwarding
        case .iTunesEPlSRewinding:
            return .rewinding
        }
    }
}

extension iTunesTrack {
    var stringID: String? {
        guard let id = id?() else {
            return nil
        }
        
        return "\(id)"
    }
    
    var track: MusicTrack? {
        guard let id = stringID else {
            return nil
        }
        
        return MusicTrack(id: id, name: name as String?, album: album as String?, artist: artist as String?)
    }
}
