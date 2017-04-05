//
//  MediaPlayerProtocol.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

enum MediaPlayerState {
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}

protocol MediaPlayerDelegate: class {
    func runningStateChanged(isRunning: Bool)
    func playerStateChanged(state: MediaPlayerState)
    func currentTrackChanged(track: MediaTrack?)
    func playerPositionChanged(position: Double)
}

protocol MediaPlayer {
    weak var delegate: MediaPlayerDelegate? { get set }
    var isRunning: Bool { get }
    var currentTrack: MediaTrack? { get }
    var playerState: MediaPlayerState { get }
    var playerPosition: Double { get }
    func changePosition(position: Double)
}

protocol MediaTrack {
    var id: String { get }
    var name: String { get }
    var album: String { get }
    var artist: String { get }
}
