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
            //TODO
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
        
        //FIXME: Audirvana Plus provides no id
        return MusicTrack(id: name, name: name, album: playingTrackAlbum ?? nil, artist: playingTrackArtist ?? nil, duration: playingTrackDuration.map({TimeInterval($0)}), url: nil)
    }
}
