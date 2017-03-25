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
    var currentTrack: MediaTrack? { return _currentTrack }
    var playerState: MediaPlayerState
    var playerPosition: Double
    
    private var _spotify: SpotifyApplication!
    private var _currentTrack: Track?
    private var positionChangeTimer: Timer!
    
    init() {
        _spotify = SBApplication(bundleIdentifier: "com.spotify.client")
        _currentTrack = _spotify.currentTrack?.track
        playerState = _spotify.playerState?.state ?? .stopped
        playerPosition = _spotify.playerPosition ?? 0
        positionChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updatePlayerState()
            self.updateCurrentTrack()
            self.updatePlayerPosition()
        }
    }
    
    private func updatePlayerState() {
        let state = _spotify.playerState?.state ?? .stopped
        if playerState == state {
            return
        }
        
        playerState = state
        delegate?.playerStateChanged(state: state)
    }
    
    private func updateCurrentTrack() {
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


