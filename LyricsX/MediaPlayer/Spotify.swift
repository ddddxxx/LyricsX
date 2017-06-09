//
//  Spotify.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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

class Spotify: MusicPlayer {
    
    static let shared = Spotify()
    
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
    
    var playerPosition: TimeInterval {
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
    
    private init?() {
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
        guard let id = id?() as? String,
            let name = name as? String else {
            return nil
        }
        
        return MusicTrack(id: id, name: name, album: album as? String, artist: artist as? String, duration: duration.map({TimeInterval($0)}))
    }
}
