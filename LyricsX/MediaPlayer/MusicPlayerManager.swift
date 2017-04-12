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
    
    var player: MusicPlayer?
    
    private var _timer: Timer!
    private var _track: MusicTrack?
    private var _state: MusicPlayerState = .stopped
    private var _position: Double = 0
    private var subscripToken: EventSubscription?
    
    private init() {
        updateMusicPlayerApplication(index: Preference[PreferredPlayerIndex])
        
        subscripToken = Preference.subscribe(key: PreferredPlayerIndex) { [unowned self] change in
            self.updateMusicPlayerApplication(index: change.newValue)
        }
        
        _timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    deinit {
        _timer.invalidate()
        subscripToken?.invalidate()
    }
    
    private func updateMusicPlayerApplication(index: Int) {
        switch index {
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
