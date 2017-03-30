//
//  LyricsHUDViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

class LyricsHUDViewController: NSViewController {
    
    
    @IBOutlet weak var lyricsScrollView: ScrollLyricsView!
    
    dynamic var isTracking = true
    var startTrackTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsScrollView.lyrics = appDelegate()?.mediaPlayerHelper.currentLyrics
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        nc.addObserver(self, selector: #selector(handleLyricsChange), name: .LyricsChange, object: nil)
        nc.addObserver(self, selector: #selector(handleScrollViewEvent), name: .NSScrollViewWillStartLiveScroll, object: lyricsScrollView)
        nc.addObserver(self, selector: #selector(handleScrollViewEvent), name: .NSScrollViewDidEndLiveScroll, object: lyricsScrollView)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - handler
    
    func handleLyricsChange(_ n: Notification) {
        lyricsScrollView.lyrics = appDelegate()?.mediaPlayerHelper.currentLyrics
    }
    
    func handlePositionChange(_ n: Notification) {
        guard isTracking else {
            return
        }
        
        guard let pos = n.userInfo?["position"] as? Double else {
            return
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
            lyricsScrollView.scroll(position: pos)
        })
    }
    
    func handleScrollViewEvent(_ n: Notification) {
        if n.name == .NSScrollViewWillStartLiveScroll {
            isTracking = false
            startTrackTimer?.invalidate()
        } else if n.name == .NSScrollViewDidEndLiveScroll {
            startTrackTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.isTracking = true
            }
        }
    }
    
}
