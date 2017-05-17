//
//  BasicExtension.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/24.
//
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

import Foundation

extension NSObject {
    
    func bind<T>(_ binding: String, to observable: Any, withKeyPath keyPath: UserDefaults.DefaultKey<T>, options: [String : Any]? = nil) {
        bind(binding, to: observable, withKeyPath: keyPath.rawValue, options: options)
    }
    
    open func addObserver<T>(_ observer: NSObject, forKeyPath keyPath: UserDefaults.DefaultKey<T>, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer? = nil) {
        addObserver(observer, forKeyPath: keyPath.rawValue, options: options, context: context)
    }
}

extension Dictionary where Key == String, Value == Any {
    
    init?(contentsOf url: URL) {
        if let data = try? Data(contentsOf: url),
            let plist = (try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)) as? [String: Any] {
            self = plist
        }
        return nil
    }
    
    func write(to url: URL) throws {
        let data = try PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: 0)
        try data.write(to: url)
    }
}

extension UserDefaults {
    
    func reset() {
        for (key, _) in dictionaryRepresentation() {
            removeObject(forKey: key)
        }
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
            } catch let error {
                log(error.localizedDescription)
                return nil
            }
        }
        set {
            if let url = newValue,
                let data = try? url.bookmarkData(options: [.withSecurityScope]) {
                self[.LyricsCustomSavingPathBookmark] = data
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
            
            let lrcFileURL = url.appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: lrcFileURL.path) {
                try fileManager.removeItem(at: lrcFileURL)
            }
            let content = contentString(withMetadata: false,
                                        ID3: true,
                                        timeTag: true,
                                        translation: true)
            try content.write(to: lrcFileURL, atomically: true, encoding: .utf8)
        } catch let error as NSError{
            log(error.localizedDescription)
            return
        }
    }
}

extension Lyrics {
    
    mutating func filtrate() {
        guard defaults[.LyricsFilterEnabled] else {
            return
        }
        
        let directFilter = defaults[.LyricsDirectFilterKey].joined(separator: "|")
        let colonFilter = defaults[.LyricsColonFilterKey].joined(separator: "|")
        let colons = [":", "：", "∶"].joined(separator: "|")
        let pattern = "\(directFilter)|((\(colonFilter))(\(colons)))"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            filtrate(using: regex)
        }
        
        if defaults[.LyricsSmartFilterEnabled] {
            smartFiltrate()
        }
    }
}
