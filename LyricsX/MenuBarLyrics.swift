//
//  MenuBarLyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class MenuBarLyrics {
    
    var enabled = UserDefaults.standard.bool(forKey: MenuBarLyricsEnabled)
    
    var statusItem: NSStatusItem?
    
    var observerTokens = [NSObjectProtocol]()
    
    init() {
        observerTokens += [NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            guard self.enabled,
                let lrc = n.userInfo?["lrc"] as? String, lrc != ""else {
                self.statusItem = nil
                return
            }
            
            self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
            self.statusItem?.highlightMode = false
            self.statusItem?.button?.title = lrc
        }]
        
        observerTokens += [NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { n in
            self.enabled = UserDefaults.standard.bool(forKey: MenuBarLyricsEnabled)
            if !self.enabled {
                self.statusItem = nil
            }
        }]
    }
    
    deinit {
        observerTokens.forEach() { token in
            NotificationCenter.default.removeObserver(token)
        }
    }
    
}
