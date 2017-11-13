import Foundation
import ScriptingBridge

class AudirvanaPlus: MusicPlayer {
    
    static let shared = AudirvanaPlus()
    
    var isRunning: Bool {
        return (_audirvanaPlus as! SBApplication).isRunning
    }
    
    var currentTrack: MusicTrack? {
        guard isRunning else { return nil }
        return _audirvanaPlus.track
    }
    
    var playerState: MusicPlayerState {
        guard isRunning else { return .stopped }
        return _audirvanaPlus.playerState?.state ?? .stopped
    }
    
    var playerPosition: TimeInterval {
        get {
            guard isRunning else { return 0 }
            return _audirvanaPlus.playerPosition ?? 0
        }
        set {
            guard isRunning else { return }
            _audirvanaPlus.setPlayerPosition?(newValue)
        }
    }
    
    private var _audirvanaPlus: AudirvanaPlusApplication
    
    private init?() {
        guard let audirvanaPlus = SBApplication(bundleIdentifier: "com.audirvana.Audirvana-Plus") else {
            return nil
        }
        _audirvanaPlus = audirvanaPlus
    }
}

// MARK - Audirvana Plus Bridge Extension

extension AudirvanaPlusPlayerStatus {
    var state: MusicPlayerState {
        switch self {
        case .stopped:  return .stopped
        case .playing:  return .playing
        case .paused:   return .paused
        }
    }
}

extension AudirvanaPlusApplication {
    var track: MusicTrack? {
        guard let name = playingTrackTitle ?? nil else {
            return nil
        }
        let album = playingTrackAlbum ?? nil
        let artist = playingTrackArtist ?? nil
        let duration = playingTrackDuration ?? nil
        
        let id = [name, album, artist, String(duration ?? 0)].flatMap{$0}.joined(separator: ":")
        
        return MusicTrack(id: id, name: name, album: album, artist: artist, duration: duration.map({TimeInterval($0)}), url: nil)
    }
}
