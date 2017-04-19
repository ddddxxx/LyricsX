//
//  BasicExtension.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/24.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import EasyPreference

extension UserDefaults {
    
    func reset() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
    }
    
}

extension EasyPreference {
    
    func lyricsSavingPath(securityScoped: inout Bool) -> URL? {
        if self[LyricsSavingPathPopUpIndex] == 0 {
            securityScoped = false
            let userPath = String(cString: getpwuid(getuid()).pointee.pw_dir)
            return URL(fileURLWithPath: userPath).appendingPathComponent("Music/LyricsX")
        } else {
            securityScoped = true
            return lyricsCustomSavingPath
        }
    }
    
    var lyricsCustomSavingPath: URL? {
        get {
            guard let data = self[LyricsCustomSavingPathBookmark] else {
                return nil
            }
            var bookmarkDataIsStale = false
            do {
                let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], bookmarkDataIsStale: &bookmarkDataIsStale)
                return url
            } catch let error {
                print(error)
                return nil
            }
        }
        set {
            if let url = newValue,
                let data = try? url.bookmarkData(options: [.withSecurityScope]) {
                self[LyricsCustomSavingPathBookmark] = data
            }
        }
    }
    
}

extension Lyrics {
    
    var fileName: String {
        let title = metadata.title?.replacingOccurrences(of: "/", with: "&") ?? ""
        let artist = metadata.artist?.replacingOccurrences(of: "/", with: "&") ?? ""
        return "\(title) - \(artist).lrc"
    }
    
}

extension Lyrics {
    
    static func loadFromLocal(title: String, artist: String) -> Lyrics? {
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
        
        guard let lrcContents = try? String(contentsOf: lrcFileURL, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        var lrc = Lyrics(lrcContents)
        lrc?.metadata.source = .Local
        lrc?.metadata.title = title
        lrc?.metadata.artist = artist
        return lrc
    }
    
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
            
            let lrcFileURL = url.appendingPathComponent(fileName)
            
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
}

extension Lyrics {
    
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
