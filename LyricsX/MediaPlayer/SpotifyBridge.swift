//
//  Spotify.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import AppKit
import ScriptingBridge


@objc enum SpotifyEPlS: Int {
    case stopped = 0x6b505353
    case playing = 0x6b505350
    case paused = 0x6b505370
};


/*
 * Spotify Suite
 */
// The Spotify application.
@objc protocol SpotifyApplication {
    @objc optional var currentTrack: SpotifyTrack {get}
    // The current playing track.
    @objc optional var soundVolume: Int {get set}
    // The sound output volume (0 = minimum, 100 = maximum)
    @objc optional var playerState: SpotifyEPlS {get}
    // Is Spotify stopped, paused, or playing?
    @objc optional var playerPosition: Double {get set}
    // The player’s position within the currently playing track in seconds.
    @objc optional var repeatingEnabled: Bool {get}
    // Is repeating enabled in the current playback context?
    @objc optional var repeating: Bool {get set}
    // Is repeating on or off?
    @objc optional var shufflingEnabled: Bool {get}
    // Is shuffling enabled in the current playback context?
    @objc optional var shuffling: Bool {get set}
    // Is shuffling on or off?
    @objc optional func nextTrack()
    // Skip to the next track.
    @objc optional func previousTrack()
    // Skip to the previous track.
    @objc optional func playpause()
    // Toggle play/pause.
    @objc optional func pause()
    // Pause playback.
    @objc optional func play()
    // Resume playback.
    @objc optional func playTrack(x: String, inContext: String)
    // Start playback of a track in the given context.
    
    /*
     * Standard Suite
     */
    // The application"s top level scripting object.
    @objc optional var name: String? {get}
    // The name of the application.
    @objc optional var frontmost: Bool {get}
    // Is this the frontmost (active) application?
    @objc optional var version: String? {get}
    // The version of the application.
}
extension SBApplication: SpotifyApplication{}


// A Spotify track.
@objc protocol SpotifyTrack {
    @objc optional var artist: String? {get}
    // The artist of the track.
    @objc optional var album: String? {get}
    // The album of the track.
    @objc optional var discNumber: Int {get}
    // The disc number of the track.
    @objc optional var duration: Int {get}
    // The length of the track in seconds.
    @objc optional var playedCount: Int {get}
    // The number of times this track has been played.
    @objc optional var trackNumber: Int {get}
    // The index of the track in its album.
    @objc optional var starred: Bool {get}
    // Is the track starred?
    @objc optional var popularity: Int {get}
    // How popular is this track? 0-100
    @objc optional func id() -> String?
    // The ID of the item.
    @objc optional var name: String? {get}
    // The name of the track.
    @objc optional var artworkUrl: String? {get}
    // The URL of the track%apos
    @objc optional var artwork: NSImage {get}
    // The property is deprecated and will never be set. Use the "artwork url" instead.
    @objc optional var albumArtist: String? {get}
    // That album artist of the track.
    @objc optional var spotifyUrl: String? {get set}
    // The URL of the track.
}
extension SBObject: SpotifyTrack{}
