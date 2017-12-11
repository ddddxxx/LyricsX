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

extension Collection {
    
    var indexes: Range<Index> {
        return startIndex..<endIndex
    }
}

extension Comparable {
    
    func clamped(to limits: Range<Self>) -> Self {
        guard limits.lowerBound <= self else { return limits.lowerBound }
        guard limits.upperBound >= self else { return limits.upperBound }
        return self
    }
}

extension NSObject {
    
    func bind<T>(_ binding: NSBindingName, to observable: Any, withKeyPath keyPath: UserDefaults.DefaultKey<T>, options: [NSBindingOption : Any]? = nil) {
        bind(binding, to: observable, withKeyPath: keyPath.rawValue, options: options)
    }
}

extension MusicPlayerName {
    
    init?(index: Int) {
        switch index {
        case 0: self = .itunes
        case 1: self = .spotify
        case 2: self = .vox
        default: return nil
        }
    }
}

extension NSFont {
    
    convenience init?(name fontName: String, size fontSize: CGFloat, fallback fallbackNames: [String]) {
        let cascadeList = fallbackNames.flatMap { NSFontDescriptor.init(name: $0, size: fontSize).matchingFontDescriptor(withMandatoryKeys: [.name, .size]) }
        let descriptor = NSFontDescriptor(fontAttributes: [.name: fontName, .cascadeList: cascadeList])
        self.init(descriptor: descriptor, size: fontSize)
    }
}

extension UserDefaults {
    
    var desktopLyricsFont: NSFont {
        return NSFont.init(name: self[.DesktopLyricsFontName],
                           size: CGFloat(self[.DesktopLyricsFontSize]),
                           fallback: self[.DesktopLyricsFontNameFallback])
            ?? NSFont.systemFont(ofSize: CGFloat(self[.DesktopLyricsFontSize]))
    }
}

extension UserDefaults {
    
    func lyricsSavingPath() -> (URL, security: Bool)? {
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
                let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], bookmarkDataIsStale: &bookmarkDataIsStale)
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
        return "\(title) - \(artist).lrc"
    }
    
}

extension Lyrics {
    
    static func loadFromLocal(title: String, artist: String) -> Lyrics? {
        guard let (url, security) = defaults.lyricsSavingPath() else {
            return nil
        }
        if security {
            guard url.startAccessingSecurityScopedResource() else {
                return nil
            }
        }
        defer {
            if security {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let titleForReading: String = title.replacingOccurrences(of: "/", with: "&")
        let artistForReading: String = artist.replacingOccurrences(of: "/", with: "&")
        let lrcFileURL = url.appendingPathComponent("\(titleForReading) - \(artistForReading).lrc")
        
        guard let lrcContents = try? String(contentsOf: lrcFileURL, encoding: String.Encoding.utf8),
            let lrc = Lyrics(lrcContents) else {
            return nil
        }
        
        lrc.metadata.source = .Local
        lrc.metadata.title = title
        lrc.metadata.artist = artist
        return lrc
    }
    
    func saveToLocal() {
        guard let (url, security) = defaults.lyricsSavingPath() else {
            return
        }
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
            var isDir = ObjCBool(false)
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
            try legacyDescription.write(to: lrcFileURL, atomically: true, encoding: .utf8)
        } catch {
            log(error.localizedDescription)
            return
        }
    }
}

extension Lyrics {
    
    func filtrate() {
        var predicates = defaults[.LyricsDirectFilterKey].map { key in
            NSPredicate { object, bindings in
                guard let object = object as? LyricsLine else { return false }
                return !object.content.contains(key)
            }
        }
        let colonCharacterSet = CharacterSet(charactersIn: ":：∶")
        predicates += defaults[.LyricsColonFilterKey].map { key in
            NSPredicate { object, bindings in
                guard let object = object as? LyricsLine else { return false }
                return !object.content.components(separatedBy: colonCharacterSet).contains { $0.starts(with: key) }
            }
        }
        if defaults[.LyricsSmartFilterEnabled] {
            let smartPredicate = NSPredicate { (object, _) -> Bool in
                guard let object = object as? LyricsLine else {
                    return false
                }
                let content = object.content
                if let idTagTitle = self.idTags[.title],
                    let idTagArtist = self.idTags[.artist],
                    content.contains(idTagTitle),
                    content.contains(idTagArtist) {
                    return false
                } else if let iTunesTitle = self.metadata.title,
                    let iTunesArtist = self.metadata.artist,
                    content.contains(iTunesTitle),
                    content.contains(iTunesArtist) {
                    return false
                }
                return true
            }
            predicates.append(smartPredicate)
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        filtrate(isIncluded: predicate)
    }
}

extension NSStoryboard {
    
    @available(macOS, obsoleted: 10.13)
    class var main: NSStoryboard? {
        guard let mainStoryboardName = Bundle.main.infoDictionary?["NSMainStoryboardFile"] as? String else {
            return nil
        }
        return NSStoryboard(name: NSStoryboard.Name(rawValue: mainStoryboardName), bundle: .main)
    }
}
