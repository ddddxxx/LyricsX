//
//  Spotify.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class Spotify: MediaPlayer {
    
    weak var delegate: MediaPlayerDelegate?
    var isRunning: Bool
    var currentTrack: MediaTrack? { return _currentTrack }
    var playerState: MediaPlayerState = .stopped
    var playerPosition: Double = 0
    
    private var _spotify: SpotifyApplication
    private var _currentTrack: Track?
    private var positionChangeTimer: Timer!
    
    init?() {
        guard let spotify = SBApplication(bundleIdentifier: "com.spotify.client") else {
            return nil
        }
        _spotify = spotify
        isRunning = (_spotify as! SBApplication).isRunning
        if isRunning {
            _currentTrack = _spotify.currentTrack?.track
            playerState = _spotify.playerState?.state ?? .stopped
            playerPosition = _spotify.playerPosition ?? 0
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
    
    private func updateRunningState() {
        let isRunningNew = (_spotify as! SBApplication).isRunning
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
        
        let state = _spotify.playerState?.state ?? .stopped
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
        
        let track = _spotify.currentTrack?.track
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
        
        playerPosition = _spotify.playerPosition ?? 0
        delegate?.playerPositionChanged(position: playerPosition)
    }
    
}

extension Spotify {
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

extension Spotify.Track: Equatable {
    public static func ==(lhs: Spotify.Track, rhs: Spotify.Track) -> Bool {
        return (lhs.id != "") && (lhs.id == rhs.id)
    }
}

// MARK - Spotify Bridge Extension

extension SpotifyEPlS {
    var state: MediaPlayerState {
        switch self {
        case .SpotifyEPlSStopped:
            return .stopped
        case .SpotifyEPlSPlaying:
            return .playing
        case .SpotifyEPlSPaused:
            return .paused
        }
    }
}

extension SpotifyTrack {
    var track: Spotify.Track {
        return Spotify.Track(id: id?() as String?,
                             name: name as String?,
                             album: album as String?,
                             artist: artist as String?)
    }
}
