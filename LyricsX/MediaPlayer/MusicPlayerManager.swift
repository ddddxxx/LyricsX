//
//  MusicPlayerManager.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/12.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import EasyPreference

class MusicPlayerManager {
    
    static let shared = MusicPlayerManager()
    
    weak var delegate: MusicPlayerDelegate?
    
    private(set) var player: MusicPlayer?
    
    private var _timer: Timer!
    private var _isRunning = false
    private var _track: MusicTrack?
    private var _state: MusicPlayerState = .stopped
    private var _position: TimeInterval = 0
    
    private init() {
        _timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.updateSelectedPlayer()
            self.updateRunningState()
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    private func updateSelectedPlayer() {
        if player?.playerState == .playing {
            return
        }
        
        let newPlayer: MusicPlayer?
        switch Preference[PreferredPlayerIndex] {
        case 0:
            newPlayer = iTunes.shared
        case 1:
            newPlayer = Spotify.shared
        case 2:
            newPlayer = Vox.shared
        default:
            newPlayer = autoSelectPlayer()
        }
        
        guard newPlayer != nil, newPlayer !== player else {
            return
        }
        
        player = newPlayer
        _isRunning = false
        _track = nil
        _state = .stopped
        _position = 0
    }
    
    private func autoSelectPlayer() -> MusicPlayer? {
        let players: [MusicPlayer?] = [
            player,
            iTunes.shared,
            Spotify.shared,
            Vox.shared,
        ]
        
        return players.first { $0?.playerState == .playing } ?? nil
    }
    
    private func updateRunningState() {
        guard let isRunning = player?.isRunning,
            _isRunning != isRunning else {
            return
        }
        
        _isRunning = isRunning
        delegate?.runningStateChanged(isRunning: _isRunning)
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
