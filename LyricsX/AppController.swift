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

import Foundation
import AppKit
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
            didChangeValue(forKey: "lyricsOffset")
            NotificationCenter.default.post(name: .currentLyricsChange, object: nil)
            if currentLyrics?.metadata.localURL == nil {
                currentLyrics?.saveToLocal()
            }
            currentLineIndex = nil
            timer?.fireDate = Date()
        }
    }
    
    var searchTask: LyricsSearchTask?
    
    var currentLineIndex: Int?
    
    var timer: Timer?
    
    @objc dynamic var lyricsOffset: Int {
        get {
            return currentLyrics?.offset ?? 0
        }
        set {
            currentLyrics?.offset = newValue
            currentLyrics?.saveToLocal()
            timer?.fireDate = Date()
        }
    }
    
    private override init() {
        super.init()
        playerManager.delegate = self
        playerManager.preferredPlayerName = MusicPlayerName(index: defaults[.PreferredPlayerIndex])
        
        timer = Timer(timeInterval: 0.1, target: self, selector: #selector(updatePlayerPosition), userInfo: nil, repeats: true)
        timer?.tolerance = 0.02
        RunLoop.current.add(timer!, forMode: .commonModes)
        
        self.currentTrackChanged(track: playerManager.player?.currentTrack)
    }
    
    func writeToiTunes(overwrite: Bool) {
        guard let player = playerManager.player as? iTunes,
            let currentLyrics = currentLyrics,
            overwrite || player.currentLyrics?.isEmpty != false else {
            return
        }
        var content = currentLyrics.lines.map { line in
            var content = line.content
            if defaults[.WriteiTunesWithTranslation],
                let translation = line.translation {
                content += "\n" + translation
            }
            return content
        }.joined(separator: "\n")
        let regex = try! NSRegularExpression(pattern: "\\n{3}")
        content = regex.stringByReplacingMatches(in: content, range: NSRange(location: 0, length: content.utf16.count), withTemplate: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        if let converter = ChineseConverter.shared {
            content = converter.convert(content)
        }
        player.currentLyrics = content
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
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil)
        if state == .playing {
            timer?.fireDate = Date()
        } else {
            timer?.fireDate = .distantFuture
        }
    }
    
    func currentTrackChanged(track: MusicTrack?) {
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
        
        var candidateLyricsURL: [(URL, Bool)] = []  // (fileURLWithoutExtension, isSecurityScoped)
        
        if defaults[.LoadLyricsBesideTrack] {
            if let fileName = track.url?.deletingPathExtension() {
                candidateLyricsURL += [
                    (fileName.appendingPathExtension("lrcx"), false),
                    (fileName.appendingPathExtension("lrc"), false),
                ]
            }
        }
        if let (url, security) = defaults.lyricsSavingPath() {
            let titleForReading = title.replacingOccurrences(of: "/", with: "&")
            let artistForReading = artist.replacingOccurrences(of: "/", with: "&")
            let fileName = url.appendingPathComponent("\(titleForReading) - \(artistForReading)")
            candidateLyricsURL += [
                (fileName.appendingPathExtension("lrcx"), security),
                (fileName.appendingPathExtension("lrc"), security),
            ]
        }
        
        for (url, security) in candidateLyricsURL {
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
                break
            }
        }
        
        #if IS_FOR_MAS
            guard defaults[.isInMASReview] == false else {
                return
            }
            checkForMASReview()
        #endif
        
        if currentLyrics == nil || currentLyrics?.metadata.localURL?.pathExtension == "lrc" {
            let duration = track.duration ?? 0
            let req = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist), title: title, artist: artist, duration: duration, limit: 5, timeout: 10)
            let task = lyricsManager.searchLyrics(request: req, using: self.lyricsReceived)
            searchTask = task
            task.resume()
        }
    }
    
    func playerPositionMutated(position: TimeInterval) {
        guard let lyrics = currentLyrics else {
            NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil)
            timer?.fireDate = .distantFuture
            return
        }
        let (index, next) = lyrics[position + lyrics.timeDelay]
        if currentLineIndex != index {
            currentLineIndex = index
            NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil)
        }
        if let next = next {
            timer?.fireDate = Date() + lyrics.lines[next].position - lyrics.timeDelay - position
        } else {
            timer?.fireDate = .distantFuture
        }
    }
    
    @objc func updatePlayerPosition() {
        guard let position = AppController.shared.playerManager.player?.playerPosition else {
            return
        }
        playerPositionMutated(position: position)
    }
    
    // MARK: LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        let track = AppController.shared.playerManager.player?.currentTrack
        guard lyrics.metadata.title == track?.title ?? "",
            lyrics.metadata.artist == track?.artist ?? "" else {
            return
        }
        
        func shoudReplace(_ from: Lyrics, to: Lyrics) -> Bool {
            if (from.metadata.source?.rawValue == defaults[.PreferredLyricsSource]) != (to.metadata.source?.rawValue == defaults[.PreferredLyricsSource]) {
                return to.metadata.source?.rawValue == defaults[.PreferredLyricsSource]
            }
            return to.quality > from.quality
        }
        
        if let current = currentLyrics, !shoudReplace(current, to: lyrics) {
            return
        }
        
        currentLyrics = lyrics
        
        if searchTask?.progress.isFinished == true,
            defaults[.WriteToiTunesAutomatically] {
            writeToiTunes(overwrite: true)
        }
    }
}

extension AppController {
    
    func importLyrics(_ lyricsString: String) {
        if let lrc = Lyrics(lyricsString),
            let track = AppController.shared.playerManager.player?.currentTrack {
            lrc.metadata.title = track.title
            lrc.metadata.artist = track.artist
            currentLyrics = lrc
        }
    }
}
