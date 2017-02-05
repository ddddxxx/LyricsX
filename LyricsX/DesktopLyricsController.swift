//
//  DesktopLyricsController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class DesktopLyricsController: NSWindowController, NSWindowDelegate {
    
    static let shared = DesktopLyricsController()
    
    convenience init() {
        let lyricsWindow = NSWindow(contentRect: NSZeroRect, styleMask: [.borderless, .fullSizeContentView, .texturedBackground], backing: .buffered, defer: false)
        lyricsWindow.backgroundColor = NSColor(deviceWhite: 0, alpha: 0.5)
        lyricsWindow.isOpaque = false
        lyricsWindow.hasShadow = false
        lyricsWindow.ignoresMouseEvents = true
        lyricsWindow.level = Int(CGWindowLevelForKey(.floatingWindow))
        lyricsWindow.collectionBehavior = .canJoinAllSpaces
        self.init(window: lyricsWindow)
        if let window = self.window {
            let visibleFrame = NSScreen.main()!.visibleFrame
            window.setFrame(visibleFrame, display: true)
            window.delegate = self
        }
    }
}
