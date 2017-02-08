//
//  MenuBarLyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class MenuBarLyrics {
    
    var statusItem: NSStatusItem?
    
    init() {
        NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            if let lrc = n.userInfo?["lrc"] as? String, lrc != "" {
                self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
                self.statusItem?.highlightMode = false
                self.statusItem?.button?.title = lrc
            } else {
                self.statusItem = nil
            }
        }
    }
    
}
