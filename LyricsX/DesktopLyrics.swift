//
//  DesktopLyricsController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SnapKit

class DesktopLyrics {
    
    var lyricsWindowController: NSWindowController!
    
    var backgroundView: NSView!
    var textView: NSTextField!
    
    var enabled = UserDefaults.standard.bool(forKey: DesktopLyricsEnabled)
    
    init() {
        let visibleFrame = NSScreen.main()!.visibleFrame
        let window = NSWindow(contentRect: visibleFrame, styleMask: [.borderless, .fullSizeContentView, .texturedBackground], backing: .buffered, defer: false)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = Int(CGWindowLevelForKey(.floatingWindow))
        window.collectionBehavior = .canJoinAllSpaces
        window.contentView?.wantsLayer=true
        lyricsWindowController = NSWindowController(window: window)
        lyricsWindowController?.showWindow(nil)
        
        backgroundView = NSView()
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = CGColor(gray: 0, alpha: 0.5)
        backgroundView.layer?.cornerRadius = 10
        window.contentView?.addSubview(backgroundView)
        
        textView = NSTextField(wrappingLabelWithString: "LyricsX")
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 28)
        textView.alignment = .center
        backgroundView.addSubview(textView)
        
        textView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(EdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
        
        backgroundView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            guard self.enabled else {
                return
            }
            
            let lrc = n.userInfo?["lrc"] as? String ?? ""
            self.backgroundView.isHidden = lrc == ""
            if let next = n.userInfo?["next"] as? String, next != "" {
                self.textView.stringValue = lrc + "\n" + next
            } else {
                self.textView.stringValue = lrc
            }
        }
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { n in
            self.enabled = UserDefaults.standard.bool(forKey: DesktopLyricsEnabled)
            self.backgroundView.isHidden = !self.enabled
        }
    }
    
}
