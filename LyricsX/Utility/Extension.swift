//
//  BasicExtension.swift
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

import Cocoa
import LyricsProvider
import MusicPlayer

extension MusicPlayerName {
    
    init?(index: Int) {
        switch index {
        case 0: self = .itunes
        case 1: self = .spotify
        case 2: self = .vox
        case 3: self = .audirvana
        default: return nil
        }
    }
}

extension MusicTrack {
    
    var lyrics: String? {
        guard let originalTrack = originalTrack,
            originalTrack.responds(to: Selector(("lyrics"))) else {
            return nil
        }
        return originalTrack.value(forKey: "lyrics") as? String
    }
    
    func setLyrics(_ lyrics: String) {
        guard let originalTrack = originalTrack,
            originalTrack.responds(to: Selector(("setLyrics:"))) else {
                return
        }
        originalTrack.setValue(lyrics, forKey: "lyrics")
    }
}

extension NSFont {
    
    convenience init?(name fontName: String, size fontSize: CGFloat, fallback fallbackNames: [String]) {
        let cascadeList = fallbackNames.compactMap {
            NSFontDescriptor(name: $0, size: fontSize)
                .matchingFontDescriptor(withMandatoryKeys: [.name, .size])
        }
        let descriptor = NSFontDescriptor(fontAttributes: [.name: fontName, .cascadeList: cascadeList])
        self.init(descriptor: descriptor, size: fontSize)
    }
}

extension UserDefaults {
    
    var desktopLyricsFont: NSFont {
        return NSFont(name: self[.DesktopLyricsFontName],
                      size: CGFloat(self[.DesktopLyricsFontSize]),
                      fallback: self[.DesktopLyricsFontNameFallback])
            ?? NSFont.systemFont(ofSize: CGFloat(self[.DesktopLyricsFontSize]))
    }
    
    var lyricsWindowFont: NSFont {
        return NSFont(name: defaults[.LyricsWindowFontName],
                      size: CGFloat(defaults[.LyricsWindowFontSize]))
            ?? NSFont.labelFont(ofSize: CGFloat(defaults[.DesktopLyricsFontSize]))
    }
}

extension UserDefaults {
    
    func lyricsSavingPath() -> (URL, security: Bool) {
        if self[.LyricsSavingPathPopUpIndex] != 0, let path = lyricsCustomSavingPath {
            return (path, true)
        } else {
            let userPath = String(cString: getpwuid(getuid()).pointee.pw_dir)
            return (URL(fileURLWithPath: userPath).appendingPathComponent("Music/LyricsX"), false)
        }
    }
    
    var lyricsCustomSavingPath: URL? {
        get {
            guard let data = self[.LyricsCustomSavingPathBookmark] else {
                return nil
            }
            var bookmarkDataIsStale = false
            do {
                let url = try URL(resolvingBookmarkData: data,
                                  options: [.withSecurityScope],
                                  bookmarkDataIsStale: &bookmarkDataIsStale)
                guard bookmarkDataIsStale == false else {
                    return nil
                }
                return url
            } catch {
                log(error.localizedDescription)
                return nil
            }
        }
        set {
            self[.LyricsCustomSavingPathBookmark] = try? newValue?.bookmarkData(options: [.withSecurityScope]) ?? nil
        }
    }
    
}

extension Lyrics {
    
    var fileName: String? {
        guard let title = metadata.title?.replacingOccurrences(of: "/", with: "&"),
            let artist = metadata.artist?.replacingOccurrences(of: "/", with: "&") else {
            return nil
        }
        return "\(title) - \(artist).lrcx"
    }
    
}

extension Lyrics {
    
    func persist() {
        let (url, security) = defaults.lyricsSavingPath()
        if security {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
        }
        defer {
            if security {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let fileManager = FileManager.default
        
        do {
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                if !isDir.boolValue {
                    return
                }
            } else {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            
            guard let lrcFileURL = fileName.map(url.appendingPathComponent) else {
                return
            }
            
            if fileManager.fileExists(atPath: lrcFileURL.path) {
                try fileManager.removeItem(at: lrcFileURL)
            }
            try description.write(to: lrcFileURL, atomically: true, encoding: .utf8)
            metadata.localURL = lrcFileURL
            metadata.needsPersist = false
        } catch {
            log(error.localizedDescription)
            return
        }
    }
}

private extension NSPredicate {
    
    static var lyricsPredicate: NSPredicate {
        _ = NSPredicate.observer
        return _lyricsPredicate
    }
    
    private static var _lyricsPredicate: NSPredicate!
    
    private static let observer = defaults.observe(.LyricsFilterKeys, options: [.new, .initial]) { _, change in
        let predicates = change.newValue.compactMap { (key: String) -> NSPredicate? in
            let isRegex = key.hasPrefix("/")
            let pattern = isRegex ? String(key.dropFirst()) : key
            let options: NSRegularExpression.Options = isRegex ? [.ignoreMetacharacters] : []
            guard let regex = try? Regex(pattern, options: options) else { return nil }
            return NSPredicate { object, _ in
                guard let object = object as? LyricsLine else { return false }
                return !regex.isMatch(object.content)
            }
        }
        _lyricsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

extension Lyrics {
    
    func filtrate() {
        filtrate(isIncluded: NSPredicate.lyricsPredicate)
    }
}

extension Lyrics {
    
    var adjustedOffset: Int {
        return offset + defaults[.GlobalLyricsOffset]
    }
    
    var adjustedTimeDelay: TimeInterval {
        return TimeInterval(adjustedOffset) / 1000
    }
}
