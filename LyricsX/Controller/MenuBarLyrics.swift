//
//  MenuBarLyrics.swift
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
import GenericID

class MenuBarLyrics: NSObject {
    
    static let shared = MenuBarLyrics()
    
    let statusItem: NSStatusItem
    var lyricsItem: NSStatusItem?
    var buttonImage = #imageLiteral(resourceName: "status_bar_icon")
    var buttonlength: CGFloat = 30
    
    private var displayLyrics = ""
    
    var statusItemObservation: DefaultsObservation?
    
    private override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateStatusItem), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        statusItemObservation = defaults.observe(keys: [.MenuBarLyricsEnabled, .CombinedMenubarLyrics], options: [.initial]) { [unowned self] in
            self.updateStatusItem()
        }
    }
    
    @objc func handleLyricsDisplay() {
        guard !defaults[.DisableLyricsWhenPaused] || AppController.shared.playerManager.player?.playbackState == .playing,
            let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
            displayLyrics = ""
            updateStatusItem()
            return
        }
        let lrc = lyrics.lines[index].content
        if lrc == displayLyrics {
            return
        }
        displayLyrics = lrc
        updateStatusItem()
    }
    
    @objc func updateStatusItem() {
        guard defaults[.MenuBarLyricsEnabled], !displayLyrics.isEmpty else {
            setImageStatusItem()
            lyricsItem = nil
            return
        }
        
        if defaults[.CombinedMenubarLyrics] {
            updateCombinedStatusLyrics()
        } else {
            updateSeparateStatusLyrics()
        }
    }
    
    func updateSeparateStatusLyrics() {
        setImageStatusItem()
        
        if lyricsItem == nil {
            lyricsItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            lyricsItem?.highlightMode = false
        }
        lyricsItem?.title = displayLyrics
    }
    
    func updateCombinedStatusLyrics() {
        lyricsItem = nil
        
        setTextStatusItem(string: displayLyrics)
        if statusItem.isVisibe {
            return
        }
        
        // truncation
        var components = displayLyrics.components(options: [.byWords])
        while !components.isEmpty, !statusItem.isVisibe {
            components.removeLast()
            let proposed = components.joined() + "..."
            setTextStatusItem(string: proposed)
        }
    }
    
    private func setTextStatusItem(string: String) {
        statusItem.title = string
        statusItem.image = nil
        statusItem.length = NSStatusItem.variableLength
    }
    
    private func setImageStatusItem() {
        statusItem.title = ""
        statusItem.image = buttonImage
        statusItem.length = buttonlength
    }
}

// MARK: - Status Item Visibility

extension NSStatusItem {
    
    fileprivate var isVisibe: Bool {
        guard let buttonFrame = button?.frame,
            let frame = button?.window?.convertToScreen(buttonFrame) else {
                return false
        }
        
        let point = CGPoint(x: frame.midX, y: frame.midY)
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(point) }) else {
            return false
        }
        let carbonPoint = CGPoint(x: point.x, y: screen.frame.height - point.y - 1)
        
        guard let element = AXUIElement.copyAt(position: carbonPoint) else {
            return false
        }
        
        return getpid() == element.pid
    }
}

extension AXUIElement {
    
    fileprivate static func copyAt(position: NSPoint) -> AXUIElement? {
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(position.x), Float(position.y), &element)
        guard error == .success else {
            return nil
        }
        return element
    }
    
    fileprivate var pid: pid_t? {
        var pid: pid_t = 0
        let error = AXUIElementGetPid(self, &pid)
        guard error == .success else {
            return nil
        }
        return pid
    }
}

extension String {
    
    func components(options: String.EnumerationOptions) -> [String] {
        var components: [String] = []
        let range = Range(uncheckedBounds: (startIndex, endIndex))
        enumerateSubstrings(in: range, options: options) { (_, _, range, _) in
            components.append(String(self[range]))
        }
        return components
    }
}
