//
//  MenuBarLyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class MenuBarLyrics: NSObject {
    
    static let shared = MenuBarLyrics()
    
    let statusItem: NSStatusItem
    var lyricsItem: NSStatusItem?
    var buttonImage = #imageLiteral(resourceName: "status_bar_icon")
    var buttonlength: CGFloat = 30
    
    private var lyrics = ""
    
    private override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(updateStatusItem), name: .NSWorkspaceDidActivateApplication, object: nil)
        Preference.addObserver(key: .MenuBarLyricsEnabled) { _ in
            self.updateStatusItem()
        }
        updateStatusItem()
    }
    
    func handlePositionChange(_ n: Notification) {
        let lrc = (n.userInfo?["lrc"] as? LyricsLine)?.sentence ?? ""
        if lrc == lyrics {
            return
        }
        
        lyrics = lrc
        updateStatusItem()
    }
    
    func updateStatusItem() {
        guard Preference[.MenuBarLyricsEnabled], lyrics != "" else {
            setImageStatusItem()
            lyricsItem = nil
            return
        }
        
        guard Preference[.CombinedMenubarLyrics] else {
            updateCombinedStatusItem()
            return
        }
        
        setTextStatusItem(string: lyrics)
        if statusItem.isVisibe {
            return
        }
        
        // truncation
        var components = lyrics.components(options: [.byWords])
        while !components.isEmpty, !statusItem.isVisibe {
            components.removeLast()
            let proposed = components.joined() + "..."
            setTextStatusItem(string: proposed)
        }
    }
    
    func updateCombinedStatusItem() {
        setImageStatusItem()
        guard lyrics != "" else {
            lyricsItem = nil
            return
        }
        
        if lyricsItem == nil {
            lyricsItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
            lyricsItem?.highlightMode = false
        }
        lyricsItem?.button?.title = lyrics
    }
    
    private func setTextStatusItem(string: String) {
        statusItem.button?.title = string
        statusItem.button?.image = nil
        statusItem.length = NSVariableStatusItemLength
    }
    
    private func setImageStatusItem() {
        statusItem.button?.title = ""
        statusItem.button?.image = buttonImage
        statusItem.length = buttonlength
    }
}


// MARK: - Status Item Visibility

extension NSStatusItem {
    
    fileprivate var isVisibe: Bool {
        let windowNumber = (button?.window?.windowNumber).map(CGWindowID.init(_:)) ?? kCGNullWindowID
        let info = CGWindowListCopyWindowInfo([.optionOnScreenAboveWindow], windowNumber)
        return CFArrayGetCount(info) == 0
    }
}

extension String {
    
    func components(options: String.EnumerationOptions) -> [String] {
        var components: [String] = []
        let range = Range(uncheckedBounds: (startIndex, endIndex))
        enumerateSubstrings(in: range, options: options) { (_, _, r, _) in
            components.append(self[r])
        }
        return components
    }
}
