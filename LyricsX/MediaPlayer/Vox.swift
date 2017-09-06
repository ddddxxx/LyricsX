//
//  Vox.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import ScriptingBridge

class Vox: MusicPlayer {
    
    static let shared = Vox()
    
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
    
    var playerPosition: TimeInterval {
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
    
    private init?() {
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
        guard let id = uniqueID ?? nil,
            let name = track ?? nil else {
            return nil
        }
        let url = trackUrl?.flatMap { URL.init(string: $0 as String) }
        
        return MusicTrack(id: id, name: name, album: album ?? nil, artist: artist ?? nil, duration: totalTime, url: url)
    }
}
