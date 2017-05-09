//
//  MusicPlayerManager.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/12.
//
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
        _timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc private func update() {
        updateSelectedPlayer()
        updateRunningState()
        updatePlayerState()
        updateCurrentTrack()
        updatePlayerPosition()
    }
    
    private func updateSelectedPlayer() {
        if player?.playerState == .playing {
            return
        }
        
        let newPlayer: MusicPlayer?
        switch defaults[.PreferredPlayerIndex] {
        case 0:
            newPlayer = iTunes.shared
        case 1:
            newPlayer = Spotify.shared
        case 2:
            newPlayer = Vox.shared
        default:
            newPlayer = autoSelectPlayer()
        }
        
        if newPlayer?.playerState != .playing {
            _timer.fireDate = Date().addingTimeInterval(1)
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
    
    private func autoSelectPlayer() -> MusicPlayer? {
        let players: [MusicPlayer?] = [
            player,
            iTunes.shared,
            Spotify.shared,
            Vox.shared,
        ]
        
        return players.first { $0?.playerState == .playing } ?? nil
    }
}
