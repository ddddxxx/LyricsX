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
import GenericID
import LyricsCore
import PlaybackControl
import OpenCC
import CombineX

class MenuBarLyrics: NSObject {
    
    static let shared = MenuBarLyrics()
    
    let statusItem: NSStatusItem
    var lyricsItem: NSStatusItem?
    var buttonImage = #imageLiteral(resourceName: "status_bar_icon")
    var buttonlength: CGFloat = 30
    
    private var screenLyrics = "" {
        didSet {
            DispatchQueue.main.async {
                self.updateStatusItem()
            }
        }
    }
    
    private var cancelBag = Set<AnyCancellable>()
    
    private override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        AppController.shared.$currentLyrics
            .combineLatest(AppController.shared.$currentLineIndex)
            .receive(on: DispatchQueue.global().cx)
            .sink(receiveValue: self.handleLyricsDisplay)
            .store(in: &cancelBag)
        observeNotification(center: workspaceNC, name: NSWorkspace.didActivateApplicationNotification) { [unowned self] _ in self.updateStatusItem() }
        observeDefaults(keys: [.MenuBarLyricsEnabled, .CombinedMenubarLyrics], options: [.initial]) { [unowned self] in self.updateStatusItem() }
    }
    
    private func handleLyricsDisplay(lyrics: Lyrics?, index: Int?) {
        guard !defaults[.DisableLyricsWhenPaused] || AppController.shared.playerManager.player?.playbackState.isPlaying == true,
            let lyrics = lyrics,
            let index = index else {
            screenLyrics = ""
            return
        }
        var newScreenLyrics = lyrics.lines[index].content
        if let converter = ChineseConverter.shared, lyrics.metadata.language?.hasPrefix("zh") == true {
            newScreenLyrics = converter.convert(newScreenLyrics)
        }
        if newScreenLyrics == screenLyrics {
            return
        }
        screenLyrics = newScreenLyrics
    }
    
    @objc private func updateStatusItem() {
        guard defaults[.MenuBarLyricsEnabled], !screenLyrics.isEmpty else {
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
    
    private func updateSeparateStatusLyrics() {
        setImageStatusItem()
        
        if lyricsItem == nil {
            lyricsItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            lyricsItem?.highlightMode = false
        }
        lyricsItem?.title = screenLyrics
    }
    
    private func updateCombinedStatusLyrics() {
        lyricsItem = nil
        
        setTextStatusItem(string: screenLyrics)
        if statusItem.isVisibe {
            return
        }
        
        // truncation
        var components = screenLyrics.components(options: [.byWords])
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

private extension NSStatusItem {
    
    var isVisibe: Bool {
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

private extension AXUIElement {
    
    static func copyAt(position: NSPoint) -> AXUIElement? {
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(position.x), Float(position.y), &element)
        guard error == .success else {
            return nil
        }
        return element
    }
    
    var pid: pid_t? {
        var pid: pid_t = 0
        let error = AXUIElementGetPid(self, &pid)
        guard error == .success else {
            return nil
        }
        return pid
    }
}

private extension String {
    
    func components(options: String.EnumerationOptions) -> [String] {
        var components: [String] = []
        let range = Range(uncheckedBounds: (startIndex, endIndex))
        enumerateSubstrings(in: range, options: options) { _, _, range, _ in
            components.append(String(self[range]))
        }
        return components
    }
}
