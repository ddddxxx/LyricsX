//
//  BasicExtension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import LyricsCore
import MusicPlayer
import Regex

extension MusicPlayerName {
    
    init?(index: Int) {
        switch index {
        case 0: self = .appleMusic
        case 1: self = .spotify
        case 2: self = .vox
        case 3: self = .audirvana
        case 4: self = .swinsian
        default: return nil
        }
    }
    
    var icon: NSImage {
        switch self {
        case .appleMusic:   return #imageLiteral(resourceName: "iTunes_icon")
        case .spotify:  return #imageLiteral(resourceName: "spotify_icon")
        case .vox:      return #imageLiteral(resourceName: "vox_icon")
        case .audirvana: return #imageLiteral(resourceName: "audirvana_icon")
        case .swinsian: return #imageLiteral(resourceName: "swinsian_icon")
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
        return NSFont(name: self[.desktopLyricsFontName],
                      size: CGFloat(self[.desktopLyricsFontSize]),
                      fallback: self[.desktopLyricsFontNameFallback])
            ?? NSFont.systemFont(ofSize: CGFloat(self[.desktopLyricsFontSize]))
    }
    
    var lyricsWindowFont: NSFont {
        return NSFont(name: defaults[.lyricsWindowFontName],
                      size: CGFloat(defaults[.lyricsWindowFontSize]))
            ?? NSFont.labelFont(ofSize: CGFloat(defaults[.desktopLyricsFontSize]))
    }
}

extension UserDefaults {
    
    func lyricsSavingPath() -> (URL, security: Bool) {
        if self[.lyricsSavingPathPopUpIndex] != 0, let path = lyricsCustomSavingPath {
            return (path, true)
        } else {
            let userPath = String(cString: getpwuid(getuid()).pointee.pw_dir)
            return (URL(fileURLWithPath: userPath).appendingPathComponent("Music/LyricsX"), false)
        }
    }
    
    var lyricsCustomSavingPath: URL? {
        get {
            guard let data = self[.lyricsCustomSavingPathBookmark] else {
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
            self[.lyricsCustomSavingPathBookmark] = try? newValue?.bookmarkData(options: [.withSecurityScope])
        }
    }
    
}

extension Lyrics {
    
    var fileName: String? {
        guard let title = metadata.title?.replacingOccurrences(of: "/", with: ":"),
            let artist = metadata.artist?.replacingOccurrences(of: "/", with: ":") else {
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
    
    private static let observer = defaults.observe(.lyricsFilterKeys, options: [.new, .initial]) { _, change in
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
        return offset + defaults[.globalLyricsOffset]
    }
    
    var adjustedTimeDelay: TimeInterval {
        return TimeInterval(adjustedOffset) / 1000
    }
}

extension NSImage {
    
    func scaled(to size: NSSize) -> NSImage {
        return NSImage(size: size, flipped: false) { rect in
            let srcRect = NSRect(origin: .zero, size: self.size)
            self.draw(in: rect, from: srcRect, operation: .copy, fraction: 1)
            return true
        }
    }
}
