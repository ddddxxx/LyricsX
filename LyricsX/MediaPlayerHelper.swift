//
//  MediaPlayerHelper.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/6.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import AppKit

class MediaPlayerHelper: MediaPlayerDelegate {
    
    var player: MediaPlayer?
    let lyricsSource = Lyrics163()
    
    var currentLyrics: Lyrics? {
        didSet {
            appDelegate()?.currentOffset = currentLyrics?.offset ?? 0
            NotificationCenter.default.post(name: .currentLyricsChange, object: nil)
        }
    }
    
    var currentLyricsLine: LyricsLine?
    var nextLyricsLine: LyricsLine?
    
    init() {
        switch Preference[PreferredPlayerIndex] {
        case 0:
            player = iTunes()
        case 1:
            player = Spotify()
        case 2:
            player = Vox()
        default:
            return
        }
        
        player?.delegate = self
        
        currentTrackChanged(track: player?.currentTrack)
    }
    
    // MARK: MediaPlayerDelegate
    
    func runningStateChanged(isRunning: Bool) {
        if Preference[LaunchAndQuitWithPlayer], !isRunning {
            NSApplication.shared().terminate(nil)
        }
    }
    
    func playerStateChanged(state: MediaPlayerState) {
        if state != .playing, Preference[DisableLyricsWhenPaused] {
            currentLyricsLine = nil
            nextLyricsLine = nil
            NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil)
        }
    }
    
    func currentTrackChanged(track: MediaTrack?) {
        currentLyrics = nil
        let info = ["lrc": "", "next": ""]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
        guard let track = track else {
            return
        }
        let title = track.name
        let artist = track.artist
        
        if let localLyrics = LyricsSourceHelper.readLocalLyrics(title: title, artist: artist) {
            currentLyrics = localLyrics
            currentLyrics?.filtrate()
        } else {
            lyricsSource.iFeelLucky(title: title, artist: artist) {
                self.lyricsReceived(lyrics: $0)
            }
        }
    }
    
    func playerPositionChanged(position: Double) {
        guard let lyrics = currentLyrics else {
            return
        }
        let lrc = lyrics[position]
        
        if currentLyricsLine == lrc.current {
            return
        }
        currentLyricsLine = lrc.current
        nextLyricsLine = lrc.next
        
        let nextLyricsSentence: String?
        if Preference[PreferBilingualLyrics] {
            nextLyricsSentence = currentLyricsLine?.translation ?? nextLyricsLine?.sentence
        } else {
            nextLyricsSentence = nextLyricsLine?.sentence
        }
        
        let info = [
            "lrc": currentLyricsLine?.sentence as Any,
            "next": nextLyricsSentence as Any,
            "position": currentLyricsLine?.position as Any,
        ]
        NotificationCenter.default.post(name: .lyricsShouldDisplay, object: nil, userInfo: info)
    }
    
    // MARK: LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        guard lyrics.metadata[.searchTitle] == player?.currentTrack?.name,
            lyrics.metadata[.searchArtist] == player?.currentTrack?.artist else {
            return
        }
        
        if let current = currentLyrics, current.grade >= lyrics.grade {
            return
        }
        
        var lyrics = lyrics
        lyrics.filtrate()
        currentLyrics = lyrics
        lyrics.saveToLocal()
    }
    
}

extension LyricsSourceHelper {
    
    static func readLocalLyrics(title: String, artist: String) -> Lyrics? {
        var securityScoped = false
        guard let url = Preference.lyricsSavingPath(securityScoped: &securityScoped) else {
            return nil
        }
        if securityScoped {
            guard url.startAccessingSecurityScopedResource() else {
                return nil
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let titleForReading: String = title.replacingOccurrences(of: "/", with: "&")
        let artistForReading: String = artist.replacingOccurrences(of: "/", with: "&")
        let lrcFileURL = url.appendingPathComponent("\(titleForReading) - \(artistForReading).lrc")
        if let lrcContents = try? String(contentsOf: lrcFileURL, encoding: String.Encoding.utf8) {
            var lrc = Lyrics(lrcContents)
            let metadata: [Lyrics.MetadataKey: String] = [
                .searchTitle: title,
                .searchArtist: artist,
                .source: "Local"
            ]
            lrc?.metadata = metadata
            return lrc
        }
        return nil
    }
    
}

extension Lyrics {
    
    func saveToLocal() {
        var securityScoped = false
        guard let url = Preference.lyricsSavingPath(securityScoped: &securityScoped) else {
            return
        }
        if securityScoped {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let fileManager = FileManager.default
        
        do {
            var isDir = ObjCBool(false)
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                if !isDir.boolValue {
                    return
                }
            } else {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            
            let titleForSaving = metadata[.searchTitle]!.replacingOccurrences(of: "/", with: "&")
            let artistForSaving = metadata[.searchArtist]!.replacingOccurrences(of: "/", with: "&")
            let lrcFileURL = url.appendingPathComponent("\(titleForSaving) - \(artistForSaving).lrc")
            
            if fileManager.fileExists(atPath: lrcFileURL.path) {
                try fileManager.removeItem(at: lrcFileURL)
            }
            let content = contentString(withMetadata: false,
                                        ID3: true,
                                        timeTag: true,
                                        translation: true)
            try content.write(to: lrcFileURL, atomically: false, encoding: .utf8)
        } catch let error as NSError{
            print(error)
            return
        }
    }
    
    mutating func filtrate() {
        guard Preference[LyricsFilterEnabled] else {
            return
        }
        
        guard let directFilter = Preference[LyricsDirectFilterKey],
            let colonFilter = Preference[LyricsColonFilterKey] else {
                return
        }
        let colons = [":", "：", "∶"]
        let directFilterPattern = directFilter.joined(separator: "|")
        let colonFilterPattern = colonFilter.joined(separator: "|")
        let colonsPattern = colons.joined(separator: "|")
        let pattern = "\(directFilterPattern)|((\(colonFilterPattern))(\(colonsPattern)))"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            filtrate(using: regex)
        }
        
        if Preference[LyricsSmartFilterEnabled] {
            smartFiltrate()
        }
    }
    
}
