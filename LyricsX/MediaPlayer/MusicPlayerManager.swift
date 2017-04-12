//
//  MusicPlayerManager.swift
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

struct MusicTrack: Equatable {
    var id:     String
    var name:   String?
    var album:  String?
    var artist: String?
    
    static func ==(lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol MusicPlayer {
    var isRunning: Bool { get }
    var currentTrack: MusicTrack? { get }
    var playerState: MusicPlayerState { get }
    var playerPosition: Double { get set }
}

protocol MusicPlayerDelegate: class {
    func runningStateChanged(isRunning: Bool)
    func playerStateChanged(state: MusicPlayerState)
    func currentTrackChanged(track: MusicTrack?)
    func playerPositionChanged(position: Double)
}

class MusicPlayerManager {
    
    static let shared = MusicPlayerManager()
    
    weak var delegate: MusicPlayerDelegate?
    
    var player: MusicPlayer?
    
    private var _timer: Timer!
    private var _track: MusicTrack?
    private var _state: MusicPlayerState = .stopped
    private var _position: Double = 0
    
    private init() {
        updateMusicPlayerApplication()
        
        _timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    deinit {
        _timer.invalidate()
    }
    
    private func updateMusicPlayerApplication() {
        switch Preference[PreferredPlayerIndex] {
        case 0:
            player = iTunes()
        case 1:
            player = Spotify()
        case 2:
            player = Vox()
        default:
            player = iTunes()
        }
    }
    
    private func updatePlayerState() {
        let state = player?.playerState ?? .stopped
        if _state == state {
            return
        }
        
        _state = state
        delegate?.playerStateChanged(state: state)
    }
    
    private func updateCurrentTrack() {
        let track = player?.currentTrack
        if _track == nil, track == nil {
            return
        }
        if let t1 = _track, let t2 = track, t1 == t2 {
            return
        }
        
        _track = track
        delegate?.currentTrackChanged(track: track)
    }
    
    private func updatePlayerPosition() {
        guard _state != .stopped, _state != .paused else {
            return
        }
        
        _position = player?.playerPosition ?? 0
        delegate?.playerPositionChanged(position: _position)
    }
}
