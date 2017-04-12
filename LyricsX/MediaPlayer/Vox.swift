//
//  Vox.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/26.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class Vox: MusicPlayer {
    
    var isRunning: Bool {
        return (_vox as! SBApplication).isRunning
    }
    
    var currentTrack: MusicTrack? {
        guard isRunning else { return nil }
        return _vox.track
    }
    
    var playerState: MusicPlayerState {
        guard isRunning else { return .stopped }
        return _vox.state
    }
    
    var playerPosition: Double {
        get {
            guard isRunning else { return 0 }
            return _vox.currentTime ?? 0
        }
        set {
            guard isRunning else { return }
            (_vox as! SBApplication).setValue(newValue, forKey: "currentTime")
        }
    }
    
    private var _vox: VoxApplication
    
    init?() {
        guard let vox = SBApplication(bundleIdentifier: "com.coppertino.Vox") else {
            return nil
        }
        _vox = vox
    }
    
}

// MARK - Vox Bridge Extension

extension VoxApplication {
    var state: MusicPlayerState {
        if playerState == 1 {
            return .playing
        } else {
            return .paused
        }
    }
    var track: MusicTrack? {
        guard let id = uniqueID as String?, id != "" else {
            return nil
        }
        return MusicTrack(id: id, name: track as String?, album: album as String?, artist: artist as String?)
    }
}
