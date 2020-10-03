//
//  MenuBarLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import CXExtensions
import CXShim
import GenericID
import LyricsCore
import MusicPlayer
import OpenCC
import SwiftCF

class MenuBarLyricsController {
    
    static let shared = MenuBarLyricsController()
    
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
    
    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        AppController.shared.$currentLyrics
            .combineLatest(AppController.shared.$currentLineIndex)
            .receive(on: DispatchQueue.lyricsDisplay.cx)
            .invoke(MenuBarLyricsController.handleLyricsDisplay, weaklyOn: self)
            .store(in: &cancelBag)
        workspaceNC.cx
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .signal()
            .invoke(MenuBarLyricsController.updateStatusItem, weaklyOn: self)
            .store(in: &cancelBag)
        defaults.publisher(for: [.menuBarLyricsEnabled, .combinedMenubarLyrics])
            .prepend()
            .invoke(MenuBarLyricsController.updateStatusItem, weaklyOn: self)
            .store(in: &cancelBag)
    }
    
    private func handleLyricsDisplay(event: (lyrics: Lyrics?, index: Int?)) {
        guard !defaults[.disableLyricsWhenPaused] || selectedPlayer.playbackState.isPlaying,
            let lyrics = event.lyrics,
            let index = event.index else {
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
        guard defaults[.menuBarLyricsEnabled], !screenLyrics.isEmpty else {
            setImageStatusItem()
            lyricsItem = nil
            return
        }
        
        if defaults[.combinedMenubarLyrics] {
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
        
        guard let element = try? AXUIElement.systemWide().element(at: carbonPoint),
            let pid = try? element.pid() else {
            return false
        }
        
        return getpid() == pid
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
