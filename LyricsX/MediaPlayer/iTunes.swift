//
//  iTunes.swift
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
    
    var currentLyrics: String? {
        get {
            return _iTunes.currentTrack?.lyrics as String?
        }
        set {
            (_iTunes.currentTrack as? SBObject)?.setValue(newValue ?? "", forKey: "lyrics")
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
