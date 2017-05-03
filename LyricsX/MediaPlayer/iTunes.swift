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
    
    static let shared = iTunes()
    
    var isRunning: Bool {
        return (_iTunes as! SBApplication).isRunning
    }
    
    var currentTrack: MusicTrack? {
        guard isRunning else { return nil }
        return _iTunes.currentTrack?.track
    }
    
    var playerState: MusicPlayerState {
        guard isRunning else { return .stopped }
        return _iTunes.playerState?.state ?? .stopped
    }
    
    var playerPosition: TimeInterval {
        get {
            guard isRunning else { return 0 }
            return _iTunes.playerPosition ?? 0
        }
        set {
            guard isRunning else { return }
            (_iTunes as! SBApplication).setValue(newValue, forKey: "playerPosition")
        }
    }
    
    private var _iTunes: iTunesApplication
    
    private init?() {
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
        guard let id = stringID,
            let name = name as? String,
            let album = album as String?,
            let artist = artist as String? else {
            return nil
        }
        
        return MusicTrack(id: id, name: name, album: album, artist: artist, duration: duration as TimeInterval?)
    }
}
