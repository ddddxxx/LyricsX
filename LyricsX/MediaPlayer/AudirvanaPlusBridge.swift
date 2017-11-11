import AppKit
import ScriptingBridge

@objc public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> Any!
}

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
    var isRunning: Bool { get }
}

// MARK: AudirvanaPlusPlayerStatus
@objc public enum AudirvanaPlusPlayerStatus : AEKeyword {
    case stopped = 0x6b505353 /* 'kPSS' */
    case playing = 0x6b505350 /* 'kPSP' */
    case paused = 0x6b505370 /* 'kPSp' */
}

// MARK: AudirvanaPlusPlayerControlType
@objc public enum AudirvanaPlusPlayerControlType : AEKeyword {
    case standalone = 0x6b435374 /* 'kCSt' */
    case library = 0x6b434c62 /* 'kCLb' */
    case iTunesIntegrated = 0x6b436954 /* 'kCiT' */
    case slave = 0x6b43536c /* 'kCSl' */
}

// MARK: AudirvanaPlusPlayerStatusEventTypesReported
@objc public enum AudirvanaPlusPlayerStatusEventTypesReported : AEKeyword {
    case none = 0x6b45764e /* 'kEvN' */
    case trackChanged = 0x6b457654 /* 'kEvT' */
    case trackAndPosition = 0x6b457650 /* 'kEvP' */
}

// MARK: AudirvanaPlusTrackType
@objc public enum AudirvanaPlusTrackType : AEKeyword {
    case audioFile = 0x6b54466c /* 'kTFl' */
    case qobuzTrack = 0x6b545142 /* 'kTQB' */
}

// MARK: AudirvanaPlusApplication
@objc public protocol AudirvanaPlusApplication: SBApplicationProtocol {
    @objc optional var playerState: AudirvanaPlusPlayerStatus { get } // Playback engine state (stopped, playing, ...)
    @objc optional var controlType: AudirvanaPlusPlayerControlType { get } // Player control type (standalone, by iTunes, by Apple Events)
    @objc optional var eventTypesReported: AudirvanaPlusPlayerStatusEventTypesReported { get } // Type of events (playback status, track change, player position within track (only in slave mode)) to be pushed
    @objc optional var playerPosition: Double { get } // player position in the track in seconds
    @objc optional var version: String { get } // Version of Audirvana Plus
    @objc optional var playingTrackTitle: String { get } // Title of currently playing track.
    @objc optional var playingTrackArtist: String { get } // Artist of currently playing track.
    @objc optional var playingTrackAlbum: String { get } // Album of currently playing track.
    @objc optional var playingTrackDuration: Int { get } // Duration of currently playing track.
    @objc optional var playingTrackAirfoillogo: Data { get } // Logo for the currently playing track.
    @objc optional func playpause() // Start playback, toggle play pause mode
    @objc optional func stop() // Stop playback
    @objc optional func pause() // Pause playback
    @objc optional func resume() // Resume playback
    @objc optional func nextTrack() // Seek to next track
    @objc optional func previousTrack() // Seek to previous track
    @objc optional func backTrack() // move to beginning of the track, or go to previous track if already at beginning
    @objc optional func setPlayingTrackType(_ type: AudirvanaPlusTrackType, URL: String!, trackID: Int) // set/change playing track (in slave mode). trackID is optional and needed only for Qobuz tracks
    @objc optional func setNextTrackType(_ type: AudirvanaPlusTrackType, URL: String!, trackID: Int) // set/change track to be played after current one (in slave mode). trackID is optional and needed only for Qobuz tracks
    @objc optional func setControlType(_ controlType: AudirvanaPlusPlayerControlType) // Player control type (standalone, by iTunes, by Apple Events)
    @objc optional func setEventTypesReported(_ eventTypesReported: AudirvanaPlusPlayerStatusEventTypesReported) // Type of events (playback status, track change, player position within track (only in slave mode)) to be pushed
    @objc optional func setPlayerPosition(_ playerPosition: Double) // player position in the track in seconds
}
extension SBApplication: AudirvanaPlusApplication {}


