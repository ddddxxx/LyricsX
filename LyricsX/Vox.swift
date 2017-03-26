//
//  Vox.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/26.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class Vox: MediaPlayer {
    
    weak var delegate: MediaPlayerDelegate?
    var currentTrack: MediaTrack? { return _currentTrack }
    var playerState: MediaPlayerState
    var playerPosition: Double
    
    private var _vox: VoxApplication
    private var _currentTrack: Track?
    private var positionChangeTimer: Timer!
    
    init?() {
        guard let vox = SBApplication(bundleIdentifier: "com.coppertino.Vox") else {
            return nil
        }
        _vox = vox
        _currentTrack = _vox.voxTrack
        playerState = _vox.state
        playerPosition = _vox.currentTime ?? 0
        positionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    deinit {
        positionChangeTimer.invalidate()
    }
    
    private func updatePlayerState() {
        let state = _vox.state
        if playerState == state {
            return
        }
        
        playerState = state
        delegate?.playerStateChanged(state: state)
    }
    
    private func updateCurrentTrack() {
        let track = _vox.voxTrack
        if _currentTrack == track {
            return
        }
        
        _currentTrack = track
        delegate?.currentTrackChanged(track: track)
    }
    
    private func updatePlayerPosition() {
        guard playerState != .stopped, playerState != .paused else {
            return
        }
        
        playerPosition = _vox.currentTime ?? 0
        delegate?.playerPositionChanged(position: playerPosition)
    }
    
}

extension Vox {
    struct Track: MediaTrack {
        var id: String
        var name: String
        var album: String
        var artist: String
        
        init(id: String?, name: String?, album: String?, artist: String?) {
            self.id = id ?? ""
            self.name = name ?? ""
            self.album = album ?? ""
            self.artist = artist ?? ""
        }
    }
}

extension Vox.Track: Equatable {
    public static func ==(lhs: Vox.Track, rhs: Vox.Track) -> Bool {
        return (lhs.id != "") && (lhs.id == rhs.id)
    }
}

// MARK - Vox Bridge Extension

extension VoxApplication {
    var state: MediaPlayerState {
        if playerState == 1 {
            return .playing
        } else {
            return .paused
        }
    }
    var voxTrack: Vox.Track {
        return Vox.Track(id: uniqueID as String?,
                         name: track as String?,
                         album: album as String?,
                         artist: artist as String?)
    }
}
