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
    var isRunning: Bool
    var currentTrack: MediaTrack? { return _currentTrack }
    var playerState: MediaPlayerState = .stopped
    var playerPosition: Double = 0
    
    private var _vox: VoxApplication
    private var _currentTrack: Track?
    private var positionChangeTimer: Timer!
    
    init?() {
        guard let vox = SBApplication(bundleIdentifier: "com.coppertino.Vox") else {
            return nil
        }
        _vox = vox
        isRunning = (_vox as! SBApplication).isRunning
        if isRunning {
            _currentTrack = _vox.voxTrack
            playerState = _vox.state
            playerPosition = _vox.currentTime ?? 0
        }
        positionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
            self.updateRunningState()
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    deinit {
        positionChangeTimer.invalidate()
    }
    
    func changePosition(position: Double) {
        (_vox as! SBApplication).setValue(position, forKey: "currentTime")
    }
    
    private func updateRunningState() {
        let isRunningNew = (_vox as! SBApplication).isRunning
        if isRunning == isRunningNew {
            return
        }
        
        isRunning = isRunningNew
        delegate?.runningStateChanged(isRunning: isRunningNew)
    }
    
    private func updatePlayerState() {
        guard isRunning else {
            return
        }
        
        let state = _vox.state
        if playerState == state {
            return
        }
        
        playerState = state
        delegate?.playerStateChanged(state: state)
    }
    
    private func updateCurrentTrack() {
        guard isRunning else {
            return
        }
        
        let track = _vox.voxTrack
        if _currentTrack == nil, track == nil {
            return
        }
        if let t1 = _currentTrack, let t2 = track, t1 == t2 {
            return
        }
        
        _currentTrack = track
        delegate?.currentTrackChanged(track: track)
    }
    
    private func updatePlayerPosition() {
        guard isRunning else {
            return
        }
        
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
    var voxTrack: Vox.Track? {
        guard let id = uniqueID, id != "" else {
            return nil
        }
        return Vox.Track(id: id as String,
                         name: track as String?,
                         album: album as String?,
                         artist: artist as String?)
    }
}
