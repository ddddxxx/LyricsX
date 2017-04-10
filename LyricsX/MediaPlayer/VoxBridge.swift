//
//  Vox.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/25.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import AppKit
import ScriptingBridge


/*
 * Standard Suite
 */
// The application"s top level scripting object.
@objc protocol VoxApplication {
    @objc optional var name: NSString {get}
    // The name of the application.
    @objc optional var frontmost: Bool {get}
    // Is this the frontmost (active) application?
    @objc optional var version: NSString {get}
    // The version of the application.
    @objc optional func quit()
    // Quit an application.
    @objc optional func pause()
    // Pause playback.
    @objc optional func play()
    // Begin playback.
    @objc optional func playpause()
    // Toggle playback between playing and paused.
    @objc optional func next()
    // Skip to the next track in the playlist.
    @objc optional func previous()
    // Skip to the previous track in the playlist.
    @objc optional func shuffle()
    // Shuffle the tracks in the playlist.
    @objc optional func playUrl(x: NSString)
    // Play specified URL.
    @objc optional func addUrl(x: NSString)
    // Add specified URL to playlist
    @objc optional func rewindForward()
    // Rewind current track forward.
    @objc optional func rewindForwardFast()
    // Rewind current track forward fast.
    @objc optional func rewindBackward()
    // Rewind current track backward.
    @objc optional func rewindBackwardFast()
    // Rewind current track backward fast.
    @objc optional func increasVolume()
    // Increas volume.
    @objc optional func decreaseVolume()
    // Decrease volume.
    @objc optional func showHidePlaylist()
    // Show/Hide playlist.
    
    /*
     * Vox Suite
     */
    // The application"s top-level scripting object.
    @objc optional var tiffArtworkData: NSData {get}
    // Current track artwork data in TIFF format.
    @objc optional var artworkImage: NSImage {get}
    // Current track artwork as an image.
    @objc optional var playerState: NSInteger {get}
    // Player state (playing = 1, paused = 0)
    @objc optional var track: NSString {get}
    // Current track title.
    @objc optional var trackUrl: NSString {get}
    // Current track URL.
    @objc optional var artist: NSString {get}
    // Current track artist.
    @objc optional var albumArtist: NSString {get}
    // Current track album artist.
    @objc optional var album: NSString {get}
    // Current track album.
    @objc optional var uniqueID: NSString {get}
    // Unique identifier for the current track.
    @objc optional var currentTime: CDouble {get set}
    // The current playback position.
    @objc optional var totalTime: CDouble {get}
    // The total time of the currenty playing track.
    @objc optional var playerVolume: CDouble {get set}
    // Player volume (0.0 to 1.0)
    @objc optional var repeatState: NSInteger {get set}
    // Player repeat state (none = 0, repeat one = 1, repeat all = 2)
}
extension SBApplication: VoxApplication{}
