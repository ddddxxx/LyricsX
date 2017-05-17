//
//  iTunes.h
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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


@objc enum iTunesEKnd: NSInteger {
    case iTunesEKndTrackListing = 0x6b54726b /* a basic listing of tracks within a playlist */
    case iTunesEKndAlbumListing = 0x6b416c62 /* a listing of a playlist grouped by album */
    case iTunesEKndCdInsert = 0x6b434469 /* a printout of the playlist for jewel case inserts */
}

@objc enum iTunesEnum: NSInteger {
    case iTunesEnumStandard = 0x6c777374 /* Standard PostScript error handling */
    case iTunesEnumDetailed = 0x6c776474 /* print a detailed report of PostScript errors */
}

@objc enum iTunesEPlS: NSInteger {
    case iTunesEPlSStopped = 0x6b505353
    case iTunesEPlSPlaying = 0x6b505350
    case iTunesEPlSPaused = 0x6b505370
    case iTunesEPlSFastForwarding = 0x6b505346
    case iTunesEPlSRewinding = 0x6b505352
}

@objc enum iTunesERpt: NSInteger {
    case iTunesERptOff = 0x6b52704f
    case iTunesERptOne = 0x6b527031
    case iTunesERptAll = 0x6b416c6c
}

@objc enum iTunesEShM: NSInteger {
    case iTunesEShMSongs = 0x6b536853
    case iTunesEShMAlbums = 0x6b536841
    case iTunesEShMGroupings = 0x6b536847
}

@objc enum iTunesEVSz: NSInteger {
    case iTunesEVSzSmall = 0x6b565353
    case iTunesEVSzMedium = 0x6b56534d
    case iTunesEVSzLarge = 0x6b56534c
}

@objc enum iTunesESrc: NSInteger {
    case iTunesESrcLibrary = 0x6b4c6962
    case iTunesESrcIPod = 0x6b506f64
    case iTunesESrcAudioCD = 0x6b414344
    case iTunesESrcMP3CD = 0x6b4d4344
    case iTunesESrcRadioTuner = 0x6b54756e
    case iTunesESrcSharedLibrary = 0x6b536864
    case iTunesESrcITunesStore = 0x6b495453
    case iTunesESrcUnknown = 0x6b556e6b
}

@objc enum iTunesESrA: NSInteger {
    case iTunesESrAAlbums = 0x6b53724c /* albums only */
    case iTunesESrAAll = 0x6b416c6c /* all text fields */
    case iTunesESrAArtists = 0x6b537252 /* artists only */
    case iTunesESrAComposers = 0x6b537243 /* composers only */
    case iTunesESrADisplayed = 0x6b537256 /* visible text fields */
    case iTunesESrASongs = 0x6b537253 /* song names only */
}

@objc enum iTunesESpK: NSInteger {
    case iTunesESpKNone = 0x6b4e6f6e
    case iTunesESpKBooks = 0x6b537041
    case iTunesESpKFolder = 0x6b537046
    case iTunesESpKGenius = 0x6b537047
    case iTunesESpKITunesU = 0x6b537055
    case iTunesESpKLibrary = 0x6b53704c
    case iTunesESpKMovies = 0x6b537049
    case iTunesESpKMusic = 0x6b53705a
    case iTunesESpKPodcasts = 0x6b537050
    case iTunesESpKPurchasedMusic = 0x6b53704d
    case iTunesESpKTVShows = 0x6b537054
}

@objc enum iTunesEMdK: NSInteger {
    case iTunesEMdKAlertTone = 0x6b4d644c /* alert tone track */
    case iTunesEMdKAudiobook = 0x6b4d6441 /* audiobook track */
    case iTunesEMdKBook = 0x6b4d6442 /* book track */
    case iTunesEMdKHomeVideo = 0x6b566448 /* home video track */
    case iTunesEMdKITunesU = 0x6b4d6449 /* iTunes U track */
    case iTunesEMdKMovie = 0x6b56644d /* movie track */
    case iTunesEMdKSong = 0x6b4d6453 /* music track */
    case iTunesEMdKMusicVideo = 0x6b566456 /* music video track */
    case iTunesEMdKPodcast = 0x6b4d6450 /* podcast track */
    case iTunesEMdKRingtone = 0x6b4d6452 /* ringtone track */
    case iTunesEMdKTVShow = 0x6b566454 /* TV show track */
    case iTunesEMdKVoiceMemo = 0x6b4d644f /* voice memo track */
    case iTunesEMdKUnknown = 0x6b556e6b
}

@objc enum iTunesEVdK: NSInteger {
    case iTunesEVdKNone = 0x6b4e6f6e /* not a video or unknown video kind */
    case iTunesEVdKHomeVideo = 0x6b566448 /* home video track */
    case iTunesEVdKMovie = 0x6b56644d /* movie track */
    case iTunesEVdKMusicVideo = 0x6b566456 /* music video track */
    case iTunesEVdKTVShow = 0x6b566454 /* TV show track */
}

@objc enum iTunesERtK: NSInteger {
    case iTunesERtKUser = 0x6b527455 /* user-specified rating */
    case iTunesERtKComputed = 0x6b527443 /* iTunes-computed rating */
}

@objc enum iTunesEAPD: NSInteger {
    case iTunesEAPDComputer = 0x6b415043
    case iTunesEAPDAirPortExpress = 0x6b415058
    case iTunesEAPDAppleTV = 0x6b415054
    case iTunesEAPDAirPlayDevice = 0x6b41504f
    case iTunesEAPDUnknown = 0x6b415055
}

@objc enum iTunesEClS: NSInteger {
    case iTunesEClSUnknown = 0x6b556e6b
    case iTunesEClSPurchased = 0x6b507572
    case iTunesEClSMatched = 0x6b4d6174
    case iTunesEClSUploaded = 0x6b55706c
    case iTunesEClSIneligible = 0x6b52656a
    case iTunesEClSRemoved = 0x6b52656d
    case iTunesEClSError = 0x6b457272
    case iTunesEClSDuplicate = 0x6b447570
    case iTunesEClSSubscription = 0x6b537562
    case iTunesEClSNoLongerAvailable = 0x6b526576
    case iTunesEClSNotUploaded = 0x6b557050
}


@objc protocol iTunesGenericMethods {
    @objc optional func printPrintDialog(printDialog: Bool, withProperties: NSDictionary, kind: iTunesEKnd, theme: NSString)
    // Print the specified object(s)
    @objc optional func close()
    // Close an object
    @objc optional func delete()
    // Delete an element from an object
    @objc optional func duplicateTo(to: SBObject) -> SBObject
    // Duplicate one or more object(s)
    @objc optional func exists() -> Bool
    // Verify if an object exists
    @objc optional func open()
    // Open the specified object(s)
    @objc optional func save()
    // Save the specified object(s)
    @objc optional func playOnce(once: Bool)
    // play the current track or the specified track or file.
    @objc optional func select()
    // select the specified object(s)
}


/*
 * iTunes Suite
 */
// The application program
@objc protocol iTunesApplication {
    @objc optional func AirPlayDevices() -> [iTunesAirPlayDevice]
    @objc optional func browserWindows() -> [iTunesBrowserWindow]
    @objc optional func encoders() -> [iTunesEncoder]
    @objc optional func EQPresets() -> [iTunesEQPreset]
    @objc optional func EQWindows() -> [iTunesEQWindow]
    @objc optional func miniplayerWindows() -> [iTunesMiniplayerWindow]
    @objc optional func playlists() -> [iTunesPlaylist]
    @objc optional func playlistWindows() -> [iTunesPlaylistWindow]
    @objc optional func sources() -> [iTunesSource]
    @objc optional func tracks() -> [iTunesTrack]
    @objc optional func videoWindows() -> [iTunesVideoWindow]
    @objc optional func visuals() -> [iTunesVisual]
    @objc optional func windows() -> [iTunesWindow]
    @objc optional var AirPlayEnabled: Bool {get}
    // is AirPlay currently enabled?
    @objc optional var converting: Bool {get}
    // is a track currently being converted?
    @objc optional var currentAirPlayDevices: [iTunesAirPlayDevice] {get set}
    // the currently selected AirPlay device(s)
    @objc optional var currentEncoder: iTunesEncoder {get set}
    // the currently selected encoder (MP3, AIFF, WAV, etc.)
    @objc optional var currentEQPreset: iTunesEQPreset {get set}
    // the currently selected equalizer preset
    @objc optional var currentPlaylist: iTunesPlaylist {get}
    // the playlist containing the currently targeted track
    @objc optional var currentStreamTitle: NSString {get}
    // the name of the current song in the playing stream (provided by streaming server)
    @objc optional var currentStreamURL: NSString {get}
    // the URL of the playing stream or streaming web site (provided by streaming server)
    @objc optional var currentTrack: iTunesTrack {get}
    // the current targeted track
    @objc optional var currentVisual: iTunesVisual {get set}
    // the currently selected visual plug-in
    @objc optional var EQEnabled: Bool {get set}
    // is the equalizer enabled?
    @objc optional var fixedIndexing: Bool {get set}
    // true if all AppleScript track indices should be independent of the play order of the owning playlist.
    @objc optional var frontmost: Bool {get set}
    // is iTunes the frontmost application?
    @objc optional var fullScreen: Bool {get set}
    // are visuals displayed using the entire screen?
    @objc optional var name: NSString {get}
    // the name of the application
    @objc optional var mute: Bool {get set}
    // has the sound output been muted?
    @objc optional var playerPosition: CDouble {get set}
    // the player’s position within the currently playing track in seconds.
    @objc optional var playerState: iTunesEPlS {get}
    // is iTunes stopped, paused, or playing?
    @objc optional var selection: SBObject {get}
    // the selection visible to the user
    @objc optional var shuffleEnabled: Bool {get set}
    // are songs played in random order?
    @objc optional var shuffleMode: iTunesEShM {get set}
    // the playback shuffle mode
    @objc optional var songRepeat: iTunesERpt {get set}
    // the playback repeat mode
    @objc optional var soundVolume: NSInteger {get set}
    // the sound output volume (0 = minimum, 100 = maximum)
    @objc optional var version: NSString {get}
    // the version of iTunes
    @objc optional var visualsEnabled: Bool {get set}
    // are visuals currently being displayed?
    @objc optional var visualSize: iTunesEVSz {get set}
    // the size of the displayed visual
    @objc optional func printPrintDialog(printDialog: Bool, withProperties: NSDictionary, kind: iTunesEKnd, theme: NSString)
    // Print the specified object(s)
    @objc optional func run()
    // Run iTunes
    @objc optional func quit()
    // Quit iTunes
    @objc optional func add(x: [NSURL], to: SBObject) -> iTunesTrack
    // add one or more files to a playlist
    @objc optional func backTrack()
    // reposition to beginning of current track or go to previous track if already at start of current track
    @objc optional func convert(x: [SBObject]) -> iTunesTrack
    // convert one or more files or tracks
    @objc optional func eject()
    // eject the specified iPod
    @objc optional func fastForward()
    // skip forward in a playing track
    @objc optional func nextTrack()
    // advance to the next track in the current playlist
    @objc optional func pause()
    // pause playback
    @objc optional func playOnce(once: Bool)
    // play the current track or the specified track or file.
    @objc optional func playpause()
    // toggle the playing/paused state of the current track
    @objc optional func previousTrack()
    // return to the previous track in the current playlist
    @objc optional func resume()
    // disable fast forward/rewind and resume playback, if playing.
    @objc optional func rewind()
    // skip backwards in a playing track
    @objc optional func stop()
    // stop playback
    @objc optional func subscribe(x: NSString)
    // subscribe to a podcast feed
    @objc optional func update()
    // update the specified iPod
    @objc optional func updateAllPodcasts()
    // update all subscribed podcast feeds
    @objc optional func updatePodcast()
    // update podcast feed
    @objc optional func openLocation(x: NSString)
    // Opens a Music Store or audio stream URL
}
extension SBApplication: iTunesApplication{}


// an item
@objc protocol iTunesItem {
    @objc optional var container: SBObject {get}
    // the container of the item
    @objc optional func id() -> NSInteger
    // the id of the item
    @objc optional var index: NSInteger {get}
    // The index of the item in internal application order.
    @objc optional var name: NSString? {get set}
    // the name of the item
    @objc optional var persistentID: NSString {get}
    // the id of the item as a hexadecimal string. This id does not change over time.
    @objc optional var properties: NSDictionary {get set}
    // every property of the item
    @objc optional func download()
    // download a cloud track or playlist, or a podcast episode
    @objc optional func reveal()
    // reveal and select a track or playlist
}
extension SBObject: iTunesItem{}


// an AirPlay device
@objc protocol iTunesAirPlayDevice: iTunesItem {
    @objc optional var active: Bool {get}
    // is the device currently being played to?
    @objc optional var available: Bool {get}
    // is the device currently available?
    @objc optional var kind: iTunesEAPD {get}
    // the kind of the device
    @objc optional var networkAddress: NSString {get}
    // the network (MAC) address of the device
    @objc optional func protected() -> Bool
    // is the device password- or passcode-protected?
    @objc optional var selected: Bool {get set}
    // is the device currently selected?
    @objc optional var supportsAudio: Bool {get}
    // does the device support audio playback?
    @objc optional var supportsVideo: Bool {get}
    // does the device support video playback?
    @objc optional var soundVolume: NSInteger {get set}
    // the output volume for the device (0 = minimum, 100 = maximum)
}
extension SBObject: iTunesAirPlayDevice{}


// a piece of art within a track or playlist
@objc protocol iTunesArtwork: iTunesItem {
    @objc optional var data: NSImage {get set}
    // data for this artwork, in the form of a picture
    @objc optional var objectDescription: NSString {get set}
    // description of artwork as a string
    @objc optional var downloaded: Bool {get}
    // was this artwork downloaded by iTunes?
    @objc optional var format: NSNumber {get}
    // the data format for this piece of artwork
    @objc optional var kind: NSInteger {get set}
    // kind or purpose of this piece of artwork
    @objc optional var rawData: NSData {get set}
    // data for this artwork, in original format
}
extension SBObject: iTunesArtwork{}


// converts a track to a specific file format
@objc protocol iTunesEncoder: iTunesItem {
    @objc optional var format: NSString {get}
    // the data format created by the encoder
}
extension SBObject: iTunesEncoder{}


// equalizer preset configuration
@objc protocol iTunesEQPreset: iTunesItem {
    @objc optional var band1: CDouble {get set}
    // the equalizer 32 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band2: CDouble {get set}
    // the equalizer 64 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band3: CDouble {get set}
    // the equalizer 125 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band4: CDouble {get set}
    // the equalizer 250 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band5: CDouble {get set}
    // the equalizer 500 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band6: CDouble {get set}
    // the equalizer 1 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band7: CDouble {get set}
    // the equalizer 2 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band8: CDouble {get set}
    // the equalizer 4 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band9: CDouble {get set}
    // the equalizer 8 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band10: CDouble {get set}
    // the equalizer 16 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var modifiable: Bool {get}
    // can this preset be modified?
    @objc optional var preamp: CDouble {get set}
    // the equalizer preamp level (-12.0 dB to +12.0 dB)
    @objc optional var updateTracks: Bool {get set}
    // should tracks which refer to this preset be updated when the preset is renamed or deleted?
}
extension SBObject: iTunesEQPreset{}


// a list of songs/streams
@objc protocol iTunesPlaylist: iTunesItem {
    @objc optional func tracks() -> [iTunesTrack]
    @objc optional func artworks() -> [iTunesArtwork]
    @objc optional var objectDescription: NSString {get set}
    // the description of the playlist
    @objc optional var disliked: Bool {get set}
    // is this playlist disliked?
    @objc optional var duration: NSInteger {get}
    // the total length of all songs (in seconds)
    @objc optional var name: NSString {get set}
    // the name of the playlist
    @objc optional var loved: Bool {get set}
    // is this playlist loved?
    @objc optional var parent: iTunesPlaylist {get}
    // folder which contains this playlist (if any)
    @objc optional var shuffle: Bool {get set}
    // play the songs in this playlist in random order? (obsolete	@objc optional var size: NSInteger {get}
    // the total size of all songs (in bytes)
    @objc optional var songRepeat: iTunesERpt {get set}
    // playback repeat mode (obsolete	@objc optional var specialKind: iTunesESpK {get}
    // special playlist kind
    @objc optional var time: NSString {get}
    // the length of all songs in MM:SS format
    @objc optional var visible: Bool {get}
    // is this playlist visible in the Source list?
    @objc optional func moveTo(to: SBObject)
    // Move playlist(s) to a new location
    @objc optional func searchFor(`for`: NSString, only: iTunesESrA) -> iTunesTrack
    // search a playlist for tracks matching the search string. Identical to entering search text in the Search field in iTunes.
}
extension SBObject: iTunesPlaylist{}


// a playlist representing an audio CD
@objc protocol iTunesAudioCDPlaylist: iTunesPlaylist {
    @objc optional func audioCDTracks() -> [iTunesAudioCDTrack]
    @objc optional var artist: NSString {get set}
    // the artist of the CD
    @objc optional var compilation: Bool {get set}
    // is this CD a compilation album?
    @objc optional var composer: NSString {get set}
    // the composer of the CD
    @objc optional var discCount: NSInteger {get set}
    // the total number of discs in this CD’s album
    @objc optional var discNumber: NSInteger {get set}
    // the index of this CD disc in the source album
    @objc optional var genre: NSString {get set}
    // the genre of the CD
    @objc optional var year: NSInteger {get set}
    // the year the album was recorded/released
}
extension SBObject: iTunesAudioCDPlaylist{}


// the master music library playlist
@objc protocol iTunesLibraryPlaylist: iTunesPlaylist {
    @objc optional func fileTracks() -> [iTunesFileTrack]
    @objc optional func URLTracks() -> [iTunesURLTrack]
    @objc optional func sharedTracks() -> [iTunesSharedTrack]
}
extension SBObject: iTunesLibraryPlaylist{}


// the radio tuner playlist
@objc protocol iTunesRadioTunerPlaylist: iTunesPlaylist {
    @objc optional func URLTracks() -> [iTunesURLTrack]
}
extension SBObject: iTunesRadioTunerPlaylist{}


// a music source (music library, CD, device, etc.)
@objc protocol iTunesSource: iTunesItem {
    @objc optional func audioCDPlaylists() -> [iTunesAudioCDPlaylist]
    @objc optional func libraryPlaylists() -> [iTunesLibraryPlaylist]
    @objc optional func playlists() -> [iTunesPlaylist]
    @objc optional func radioTunerPlaylists() -> [iTunesRadioTunerPlaylist]
    @objc optional func subscriptionPlaylists() -> [iTunesSubscriptionPlaylist]
    @objc optional func userPlaylists() -> [iTunesUserPlaylist]
    @objc optional var capacity: CLong {get}
    // the total size of the source if it has a fixed size
    @objc optional var freeSpace: CLong {get}
    // the free space on the source if it has a fixed size
    @objc optional var kind: iTunesESrc {get}
    @objc optional func eject()
    // eject the specified iPod
    @objc optional func update()
    // update the specified iPod
}
extension SBObject: iTunesSource{}


// a subscription playlist from Apple Music
@objc protocol iTunesSubscriptionPlaylist: iTunesPlaylist {
    @objc optional func fileTracks() -> [iTunesFileTrack]
    @objc optional func URLTracks() -> [iTunesURLTrack]
}
extension SBObject: iTunesSubscriptionPlaylist{}


// playable audio source
@objc protocol iTunesTrack: iTunesItem {
    @objc optional func artworks() -> [iTunesArtwork]
    @objc optional var album: NSString {get set}
    // the album name of the track
    @objc optional var albumArtist: NSString {get set}
    // the album artist of the track
    @objc optional var albumDisliked: Bool {get set}
    // is the album for this track disliked?
    @objc optional var albumLoved: Bool {get set}
    // is the album for this track loved?
    @objc optional var albumRating: NSInteger {get set}
    // the rating of the album for this track (0 to 100)
    @objc optional var albumRatingKind: iTunesERtK {get}
    // the rating kind of the album rating for this track
    @objc optional var artist: NSString {get set}
    // the artist/source of the track
    @objc optional var bitRate: NSInteger {get}
    // the bit rate of the track (in kbps)
    @objc optional var bookmark: CDouble {get set}
    // the bookmark time of the track in seconds
    @objc optional var bookmarkable: Bool {get set}
    // is the playback position for this track remembered?
    @objc optional var bpm: NSInteger {get set}
    // the tempo of this track in beats per minute
    @objc optional var category: NSString {get set}
    // the category of the track
    @objc optional var cloudStatus: iTunesEClS {get}
    // the iCloud status of the track
    @objc optional var comment: NSString {get set}
    // freeform notes about the track
    @objc optional var compilation: Bool {get set}
    // is this track from a compilation album?
    @objc optional var composer: NSString {get set}
    // the composer of the track
    @objc optional var databaseID: NSInteger {get}
    // the common, unique ID for this track. If two tracks in different playlists have the same database ID, they are sharing the same data.
    @objc optional var dateAdded: NSDate {get}
    // the date the track was added to the playlist
    @objc optional var objectDescription: NSString {get set}
    // the description of the track
    @objc optional var discCount: NSInteger {get set}
    // the total number of discs in the source album
    @objc optional var discNumber: NSInteger {get set}
    // the index of the disc containing this track on the source album
    @objc optional var disliked: Bool {get set}
    // is this track disliked?
    @objc optional var downloaderAppleID: NSString {get}
    // the Apple ID of the person who downloaded this track
    @objc optional var downloaderName: NSString {get}
    // the name of the person who downloaded this track
    @objc optional var duration: CDouble {get}
    // the length of the track in seconds
    @objc optional var enabled: Bool {get set}
    // is this track checked for playback?
    @objc optional var episodeID: NSString {get set}
    // the episode ID of the track
    @objc optional var episodeNumber: NSInteger {get set}
    // the episode number of the track
    @objc optional var EQ: NSString {get set}
    // the name of the EQ preset of the track
    @objc optional var finish: CDouble {get set}
    // the stop time of the track in seconds
    @objc optional var gapless: Bool {get set}
    // is this track from a gapless album?
    @objc optional var genre: NSString {get set}
    // the music/audio genre (category) of the track
    @objc optional var grouping: NSString {get set}
    // the grouping (piece) of the track. Generally used to denote movements within a classical work.
    @objc optional var kind: NSString {get}
    // a text description of the track
    @objc optional var longDescription: NSString {get set}
    @objc optional var loved: Bool {get set}
    // is this track loved?
    @objc optional var lyrics: NSString {get set}
    // the lyrics of the track
    @objc optional var mediaKind: iTunesEMdK {get set}
    // the media kind of the track
    @objc optional var modificationDate: NSDate {get}
    // the modification date of the content of this track
    @objc optional var movement: NSString {get set}
    // the movement name of the track
    @objc optional var movementCount: NSInteger {get set}
    // the total number of movements in the work
    @objc optional var movementNumber: NSInteger {get set}
    // the index of the movement in the work
    @objc optional var playedCount: NSInteger {get set}
    // number of times this track has been played
    @objc optional var playedDate: NSDate {get set}
    // the date and time this track was last played
    @objc optional var purchaserAppleID: NSString {get}
    // the Apple ID of the person who purchased this track
    @objc optional var purchaserName: NSString {get}
    // the name of the person who purchased this track
    @objc optional var rating: NSInteger {get set}
    // the rating of this track (0 to 100)
    @objc optional var ratingKind: iTunesERtK {get}
    // the rating kind of this track
    @objc optional var releaseDate: NSDate {get}
    // the release date of this track
    @objc optional var sampleRate: NSInteger {get}
    // the sample rate of the track (in Hz)
    @objc optional var seasonNumber: NSInteger {get set}
    // the season number of the track
    @objc optional var shufflable: Bool {get set}
    // is this track included when shuffling?
    @objc optional var skippedCount: NSInteger {get set}
    // number of times this track has been skipped
    @objc optional var skippedDate: NSDate {get set}
    // the date and time this track was last skipped
    @objc optional var show: NSString {get set}
    // the show name of the track
    @objc optional var sortAlbum: NSString {get set}
    // override string to use for the track when sorting by album
    @objc optional var sortArtist: NSString {get set}
    // override string to use for the track when sorting by artist
    @objc optional var sortAlbumArtist: NSString {get set}
    // override string to use for the track when sorting by album artist
    @objc optional var sortName: NSString {get set}
    // override string to use for the track when sorting by name
    @objc optional var sortComposer: NSString {get set}
    // override string to use for the track when sorting by composer
    @objc optional var sortShow: NSString {get set}
    // override string to use for the track when sorting by show name
    @objc optional var size: CLong {get}
    // the size of the track (in bytes)
    @objc optional var start: CDouble {get set}
    // the start time of the track in seconds
    @objc optional var time: NSString {get}
    // the length of the track in MM:SS format
    @objc optional var trackCount: NSInteger {get set}
    // the total number of tracks on the source album
    @objc optional var trackNumber: NSInteger {get set}
    // the index of the track on the source album
    @objc optional var unplayed: Bool {get set}
    // is this track unplayed?
    @objc optional var videoKind: iTunesEVdK {get set}
    // kind of video track
    @objc optional var volumeAdjustment: NSInteger {get set}
    // relative volume adjustment of the track (-100% to 100%)
    @objc optional var work: NSString {get set}
    // the work name of the track
    @objc optional var year: NSInteger {get set}
    // the year the track was recorded/released
}
extension SBObject: iTunesTrack{}


// a track on an audio CD
@objc protocol iTunesAudioCDTrack: iTunesTrack {
    @objc optional var location: NSURL {get}
    // the location of the file represented by this track
}
extension SBObject: iTunesAudioCDTrack{}


// a track representing an audio file (MP3, AIFF, etc.)
@objc protocol iTunesFileTrack: iTunesTrack {
    @objc optional var location: NSURL {get set}
    // the location of the file represented by this track
    @objc optional func refresh()
    // update file track information from the current information in the track’s file
}
extension SBObject: iTunesFileTrack{}


// a track residing in a shared library
@objc protocol iTunesSharedTrack: iTunesTrack {
}
extension SBObject: iTunesSharedTrack{}


// a track representing a network stream
@objc protocol iTunesURLTrack: iTunesTrack {
    @objc optional var address: NSString {get set}
    // the URL for this track
}
extension SBObject: iTunesURLTrack{}


// custom playlists created by the user
@objc protocol iTunesUserPlaylist: iTunesPlaylist {
    @objc optional func fileTracks() -> [iTunesFileTrack]
    @objc optional func URLTracks() -> [iTunesURLTrack]
    @objc optional func sharedTracks() -> [iTunesSharedTrack]
    @objc optional var shared: Bool {get set}
    // is this playlist shared?
    @objc optional var smart: Bool {get}
    // is this a Smart Playlist?
    @objc optional var genius: Bool {get}
    // is this a Genius Playlist?
}
extension SBObject: iTunesUserPlaylist{}


// a folder that contains other playlists
@objc protocol iTunesFolderPlaylist: iTunesUserPlaylist {
}
extension SBObject: iTunesFolderPlaylist{}


// a visual plug-in
@objc protocol iTunesVisual: iTunesItem {
}
extension SBObject: iTunesVisual{}


// any window
@objc protocol iTunesWindow: iTunesItem {
    @objc optional var bounds: NSRect {get set}
    // the boundary rectangle for the window
    @objc optional var closeable: Bool {get}
    // does the window have a close button?
    @objc optional var collapseable: Bool {get}
    // does the window have a collapse button?
    @objc optional var collapsed: Bool {get set}
    // is the window collapsed?
    @objc optional var fullScreen: Bool {get set}
    // is the window full screen?
    @objc optional var position: NSPoint {get set}
    // the upper left position of the window
    @objc optional var resizable: Bool {get}
    // is the window resizable?
    @objc optional var visible: Bool {get set}
    // is the window visible?
    @objc optional var zoomable: Bool {get}
    // is the window zoomable?
    @objc optional var zoomed: Bool {get set}
    // is the window zoomed?
}
extension SBObject: iTunesWindow{}


// the main iTunes window
@objc protocol iTunesBrowserWindow: iTunesWindow {
    @objc optional var selection: SBObject {get}
    // the selected songs
    @objc optional var view: iTunesPlaylist {get set}
    // the playlist currently displayed in the window
}
extension SBObject: iTunesBrowserWindow{}


// the iTunes equalizer window
@objc protocol iTunesEQWindow: iTunesWindow {
}
extension SBObject: iTunesEQWindow{}


// the miniplayer window
@objc protocol iTunesMiniplayerWindow: iTunesWindow {
}
extension SBObject: iTunesMiniplayerWindow{}


// a sub-window showing a single playlist
@objc protocol iTunesPlaylistWindow: iTunesWindow {
    @objc optional var selection: SBObject {get}
    // the selected songs
    @objc optional var view: iTunesPlaylist {get}
    // the playlist displayed in the window
}
extension SBObject: iTunesPlaylistWindow{}


// the video window
@objc protocol iTunesVideoWindow: iTunesWindow {
}
extension SBObject: iTunesVideoWindow{}


