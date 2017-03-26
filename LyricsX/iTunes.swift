//
//  iTunes.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import ScriptingBridge

class iTunes: MediaPlayer {
    
    weak var delegate: MediaPlayerDelegate?
    var currentTrack: MediaTrack? { return _currentTrack }
    var playerState: MediaPlayerState
    var playerPosition: Double
    
    private var _iTunes: iTunesApplication
    private var _currentTrack: Track?
    private var positionChangeTimer: Timer!
    
    init?() {
        guard let iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes") else {
            return nil
        }
        self._iTunes = iTunes
        _currentTrack = _iTunes.currentTrack?.track
        playerState = _iTunes.playerState?.state ?? .stopped
        playerPosition = _iTunes.playerPosition ?? 0
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
        let state = _iTunes.playerState?.state ?? .stopped
        if playerState == state {
            return
        }
        
        playerState = state
        delegate?.playerStateChanged(state: state)
    }
    
    private func updateCurrentTrack() {
        let track = _iTunes.currentTrack?.track
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
        
        playerPosition = _iTunes.playerPosition ?? 0
        delegate?.playerPositionChanged(position: playerPosition)
    }
    
}

extension iTunes {
    struct Track: MediaTrack {
        var rawID: Int
        var id: String {
            return "\(rawID)"
        }
        var name: String
        var album: String
        var artist: String
        
        init(id: Int?, name: String?, album: String?, artist: String?) {
            self.rawID = id ?? 0
            self.name = name ?? ""
            self.album = album ?? ""
            self.artist = artist ?? ""
        }
    }
}

extension iTunes.Track: Equatable {
    public static func ==(lhs: iTunes.Track, rhs: iTunes.Track) -> Bool {
        return (lhs.rawID != 0) && (lhs.rawID == rhs.rawID)
    }
}

// MARK - iTunes Bridge Extension

extension iTunesEPlS {
    var state: MediaPlayerState {
        switch self {
        case .iTunesEPlSStopped:
            return .stopped
        case .iTunesEPlSPlaying:
            return .playing
        case .iTunesEPlSPaused:
            return .paused
        case .iTunesEPlSFastForwarding:
            return .fastForwarding
        case .iTunesEPlSRewinding:
            return .rewinding
        }
    }
}

extension iTunesTrack {
    var track: iTunes.Track {
        return iTunes.Track(id: id?() as Int?,
                            name: name as String?,
                            album: album as String?,
                            artist: artist as String?)
    }
}
