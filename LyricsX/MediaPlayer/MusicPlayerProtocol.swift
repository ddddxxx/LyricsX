//
//  MusicPlayerProtocol.swift
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

enum MusicPlayerState {
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}

struct MusicTrack {
    var id:     String
    var name:   String
    var album:  String?
    var artist: String?
    var duration: TimeInterval?
}

protocol MusicPlayer: class {
    
    var isRunning: Bool { get }
    
    var currentTrack: MusicTrack? { get }
    
    var playerState: MusicPlayerState { get }
    
    var playerPosition: TimeInterval { get set }
}

protocol MusicPlayerDelegate: class {
    
    func runningStateChanged(isRunning: Bool)
    
    func playerStateChanged(state: MusicPlayerState)
    
    func currentTrackChanged(track: MusicTrack?)
    
    func playerPositionChanged(position: TimeInterval)
}

extension MusicTrack: Equatable {
    
    static func ==(lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        return lhs.id == rhs.id
    }
}
