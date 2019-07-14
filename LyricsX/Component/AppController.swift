//
//  AppController.swift
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
import Crashlytics
import LyricsProvider
import MusicPlayer
import OpenCC

class AppController: NSObject, MusicPlayerManagerDelegate {
    
    static let shared = AppController()
    
    let lyricsManager = LyricsProviderManager()
    let playerManager = MusicPlayerManager()
    
    var currentLyrics: Lyrics? {
        willSet {
            willChangeValue(forKey: "lyricsOffset")
        }
        didSet {
            currentLyrics?.filtrate()
            currentLyrics?.recognizeLanguage()
            didChangeValue(forKey: "lyricsOffset")
            currentLineIndex = nil
            postNotification(name: .currentLyricsChange)
            timer?.fireDate = Date()
        }
    }
    
    var searchRequest: LyricsSearchRequest?
    var searchProgress: Progress?
    
    var currentLineIndex: Int?
    
    var timer: Timer?
    
    @objc dynamic var lyricsOffset: Int {
        get {
            return currentLyrics?.offset ?? 0
        }
        set {
            currentLyrics?.offset = newValue
            currentLyrics?.metadata.needsPersist = true
            timer?.fireDate = Date()
        }
    }
    
    private override init() {
        super.init()
        playerManager.delegate = self
        playerManager.preferredPlayerName = MusicPlayerName(index: defaults[.PreferredPlayerIndex])
        
        timer = Timer(timeInterval: 0.1, target: self, selector: #selector(updatePlayerPosition), userInfo: nil, repeats: true)
        timer?.tolerance = 0.02
        RunLoop.current.add(timer!, forMode: .common)
        
        currentTrackChanged(track: playerManager.player?.currentTrack)
    }
    
    func writeToiTunes(overwrite: Bool) {
        guard let player = playerManager.player as? iTunes,
            let currentLyrics = currentLyrics,
            overwrite || player.currentTrack?.lyrics?.isEmpty != false else {
            return
        }
        var content = currentLyrics.lines.map { line -> String in
            var content = line.content
            if let converter = ChineseConverter.shared {
                content = converter.convert(content)
            }
            if defaults[.WriteiTunesWithTranslation] {
                // TODO: tagged translation
                let code = currentLyrics.metadata.translationLanguages.first
                if var translation = line.attachments.translation(languageCode: code) {
                    if let converter = ChineseConverter.shared {
                        translation = converter.convert(translation)
                    }
                    content += "\n" + translation
                }
            }
            return content
        }.joined(separator: "\n")
        // swiftlint:disable:next force_try
        let regex = try! Regex("\\n{3}")
        _ = regex.replaceMatches(in: &content, withTemplate: "\n\n")
        player.currentTrack?.setLyrics(content)
    }
    
    // MARK: MusicPlayerManagerDelegate
    
    func runningStateChanged(isRunning: Bool) {
        if !isRunning, defaults[.LaunchAndQuitWithPlayer] {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func currentPlayerChanged(player: MusicPlayer?) {
        currentTrackChanged(track: player?.currentTrack)
    }
    
    func playbackStateChanged(state: MusicPlaybackState) {
        postNotification(name: .lyricsShouldDisplay)
        if state == .playing {
            timer?.fireDate = Date()
        } else {
            timer?.fireDate = .distantFuture
        }
    }
    
    func currentTrackChanged(track: MusicTrack?) {
        postNotification(name: .currentTrackChange)
        if currentLyrics?.metadata.needsPersist == true {
            currentLyrics?.persist()
        }
        currentLyrics = nil
        currentLineIndex = nil
        guard let track = track else {
            return
        }
        // FIXME: deal with optional value
        let title = track.title ?? ""
        let artist = track.artist ?? ""
        
        guard !defaults[.NoSearchingTrackIds].contains(track.id) else {
            return
        }
        
        var candidateLyricsURL: [(URL, Bool, Bool)] = []  // (fileURL, isSecurityScoped, needsSearching)
        
        if defaults[.LoadLyricsBesideTrack] {
            if let fileName = track.url?.deletingPathExtension() {
                candidateLyricsURL += [
                    (fileName.appendingPathExtension("lrcx"), false, false),
                    (fileName.appendingPathExtension("lrc"), false, false)
                ]
            }
        }
        let (url, security) = defaults.lyricsSavingPath()
        let titleForReading = title.replacingOccurrences(of: "/", with: "&")
        let artistForReading = artist.replacingOccurrences(of: "/", with: "&")
        let fileName = url.appendingPathComponent("\(titleForReading) - \(artistForReading)")
        candidateLyricsURL += [
            (fileName.appendingPathExtension("lrcx"), security, false),
            (fileName.appendingPathExtension("lrc"), security, true)
        ]
        
        for (url, security, needsSearching) in candidateLyricsURL {
            if security {
                guard url.startAccessingSecurityScopedResource() else {
                    continue
                }
            }
            defer {
                if security {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if let lrcContents = try? String(contentsOf: url, encoding: String.Encoding.utf8),
                let lyrics = Lyrics(lrcContents) {
                lyrics.metadata.localURL = url
                lyrics.metadata.title = title
                lyrics.metadata.artist = artist
                currentLyrics = lyrics
                Answers.logCustomEvent(withName: "Load Local Lyrics")
                if needsSearching {
                    break
                } else {
                    return
                }
            }
        }
        
        #if IS_FOR_MAS
            guard defaults[.isInMASReview] == false else {
                return
            }
            checkForMASReview()
        #endif
        
        if let album = track.album, defaults[.NoSearchingAlbumNames].contains(album) {
            return
        }
        
        let duration = track.duration ?? 0
        let req = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist),
                                      title: title,
                                      artist: artist,
                                      duration: duration,
                                      limit: 5,
                                      timeout: 10)
        searchRequest = req
        searchProgress = lyricsManager.searchLyrics(request: req, using: self.lyricsReceived)
        Answers.logCustomEvent(withName: "Search Lyrics Automatically", customAttributes: ["override": currentLyrics == nil ? 0 : 1])
    }
    
    func playerPositionMutated(position: TimeInterval) {
        guard let lyrics = currentLyrics else {
            postNotification(name: .lyricsShouldDisplay)
            timer?.fireDate = .distantFuture
            return
        }
        let (index, next) = lyrics[position + lyrics.adjustedTimeDelay]
        if currentLineIndex != index {
            currentLineIndex = index
            postNotification(name: .lyricsShouldDisplay)
        }
        if let next = next {
            timer?.fireDate = Date() + lyrics.lines[next].position - lyrics.adjustedTimeDelay - position
        } else {
            timer?.fireDate = .distantFuture
        }
    }
    
    @objc func updatePlayerPosition() {
        guard let position = playerManager.player?.playerPosition else {
            return
        }
        playerPositionMutated(position: position)
    }
    
    // MARK: LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        guard let req = searchRequest,
            lyrics.metadata.request == req else {
            return
        }
        if defaults[.StrictSearchEnabled] && !lyrics.isMatched() {
            return
        }
        if let current = currentLyrics, current.quality >= lyrics.quality {
            return
        }
        lyrics.metadata.needsPersist = true
        currentLyrics = lyrics

        if searchProgress?.isFinished == true,
            defaults[.WriteToiTunesAutomatically] {
            writeToiTunes(overwrite: true)
        }
    }
}

extension AppController {
    
    func importLyrics(_ lyricsString: String) throws {
        guard let lrc = Lyrics(lyricsString) else {
            let errorInfo = [
                NSLocalizedDescriptionKey: "Invalid lyric file",
                NSLocalizedRecoverySuggestionErrorKey: "Please try another one."
            ]
            let error = NSError(domain: lyricsXErrorDomain, code: 0, userInfo: errorInfo)
            throw error
        }
        guard let track = playerManager.player?.currentTrack else {
            let errorInfo = [
                NSLocalizedDescriptionKey: "No music playing",
                NSLocalizedRecoverySuggestionErrorKey: "Play a music and try again."
            ]
            let error = NSError(domain: lyricsXErrorDomain, code: 0, userInfo: errorInfo)
            throw error
        }
        lrc.metadata.title = track.title
        lrc.metadata.artist = track.artist
        lrc.metadata.needsPersist = true
        currentLyrics = lrc
        if let index = defaults[.NoSearchingTrackIds].firstIndex(of: track.id) {
            defaults[.NoSearchingTrackIds].remove(at: index)
        }
        if let index = defaults[.NoSearchingAlbumNames].firstIndex(of: track.album ?? "") {
            defaults[.NoSearchingAlbumNames].remove(at: index)
        }
    }
}
