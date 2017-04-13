//
//  MusicPlayerProtocol.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/12.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
    var name:   String?
    var album:  String?
    var artist: String?
    var duration: TimeInterval?
}

protocol MusicPlayer {
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
