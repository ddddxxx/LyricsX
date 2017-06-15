//
//  LyricsHUDViewController.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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

class LyricsHUDViewController: NSViewController, ScrollLyricsViewDelegate, DragNDropDelegate {
    
    @IBOutlet weak var dragNDropView: DragNDropView!
    @IBOutlet weak var lyricsScrollView: ScrollLyricsView!
    
    dynamic var isTracking = true
    
    override func awakeFromNib() {
        view.window?.do {
            $0.titlebarAppearsTransparent = true
            $0.titleVisibility = .hidden
            $0.styleMask.insert(.borderless)
        }
        let accessory = self.storyboard?.instantiateController(withIdentifier: "LyricsHUDAccessory") as! LyricsHUDAccessoryViewController
        accessory.layoutAttribute = .right
        view.window?.addTitlebarAccessoryViewController(accessory)
        
        dragNDropView.dragDelegate = self
        lyricsScrollView.delegate = self
        lyricsScrollView.setupTextContents(lyrics: AppController.shared.currentLyrics)
        
        NotificationCenter.default.do {
            $0.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
            $0.addObserver(self, selector: #selector(handleLyricsChange), name: .LyricsChange, object: nil)
            $0.addObserver(self, selector: #selector(handleScrollViewWillStartScroll), name: .NSScrollViewWillStartLiveScroll, object: lyricsScrollView)
        }
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func doubleClickLyricsLine(at position: TimeInterval) {
        let pos = position - (AppController.shared.currentLyrics?.timeDelay ?? 0)
        MusicPlayerManager.shared.player?.playerPosition = pos
        isTracking = true
    }
    
    // MARK: - handler
    
    func handleLyricsChange(_ n: Notification) {
        DispatchQueue.main.async {
            self.lyricsScrollView.setupTextContents(lyrics: AppController.shared.currentLyrics)
        }
    }
    
    func handlePositionChange(_ n: Notification) {
        guard var pos = n.userInfo?["position"] as? TimeInterval else {
            return
        }
        pos += AppController.shared.currentLyrics?.timeDelay ?? 0
        lyricsScrollView.highlight(position: pos)
        guard isTracking else {
            return
        }
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                context.timingFunction = .mystery
                self.lyricsScrollView.scroll(position: pos)
            })
        }
    }
    
    func handleScrollViewWillStartScroll(_ n: Notification) {
        isTracking = false
    }
    
    // MARK: DragNDrop Delegate
    
    func dragFinished(content: String) {
        AppController.shared.importLyrics(content)
    }
    
}

class LyricsHUDAccessoryViewController: NSTitlebarAccessoryViewController {
    
    override func viewWillAppear() {
        view.window?.level = Int(CGWindowLevelForKey(.normalWindow))
    }
    
    @IBAction func lockAction(_ sender: NSButton) {
        if sender.state == NSOnState {
            view.window?.level = Int(CGWindowLevelForKey(.modalPanelWindow))
        } else {
            view.window?.level = Int(CGWindowLevelForKey(.normalWindow))
        }
    }
    
}
