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

extension NSMenuItem {
    
    @objc var isHiddenInMASVersion: Bool {
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
        set {
            #if IS_FOR_MAS
            if newValue, isFromMacAppStore {
                isHidden = true
            }
            #endif
        }
    }
    
    @objc var isHiddenDuringMASReview: Bool {
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
        set {
            #if IS_FOR_MAS
            if newValue, defaults[.isInMASReview] != false {
                isHidden = true
            }
            #endif
        }
    }
}

extension NSView {
    
    @objc var isRemovedDuringMASReview: Bool {
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
        set {
            #if IS_FOR_MAS
            if newValue, defaults[.isInMASReview] != false {
                removeFromSuperview()
            }
            #endif
        }
    }
}

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
            try description.write(to: lrcFileURL, atomically: true, encoding: .utf8)
            metadata.localURL = lrcFileURL
            metadata.needsPersist = false
        } catch {
            log(error.localizedDescription)
            return
        }
    }
}

extension Lyrics {
    
    func filtrate() {
        let predicates = defaults[.LyricsFilterKeys].compactMap { (key: String) -> NSPredicate? in
            if key.hasPrefix("/") {
                guard let regex = try? Regex(String(key.dropFirst())) else { return nil }
                return NSPredicate { object, _ in
                    guard let object = object as? LyricsLine else { return false }
                    return !regex.isMatch(object.content)
                }
            } else {
                return NSPredicate { object, _ in
                    guard let object = object as? LyricsLine else { return false }
                    return !object.content.contains(key)
                }
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        filtrate(isIncluded: predicate)
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

extension NSTextField {
    
    @available(macOS, obsoleted: 10.12)
    convenience init(labelWithString stringValue: String) {
        self.init()
        self.stringValue = stringValue
        isEditable = false
        isSelectable = false
        textColor = .labelColor
        backgroundColor = .controlColor
        drawsBackground = false
        isBezeled = false
        alignment = .natural
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
        lineBreakMode = .byClipping
        cell?.isScrollable = true
        cell?.wraps = false
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

extension NSAnimationContext {
    
    @available(macOS, obsoleted: 10.12)
    class func runAnimationGroup(_ changes: (NSAnimationContext) -> Void) {
        runAnimationGroup(changes, completionHandler: nil)
    }
}
