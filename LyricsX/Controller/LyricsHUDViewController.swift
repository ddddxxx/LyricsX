//
//  LyricsHUDViewController.swift
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
import MusicPlayer

class LyricsHUDViewController: NSViewController, ScrollLyricsViewDelegate, DragNDropDelegate {
    
    @IBOutlet weak var dragNDropView: DragNDropView!
    @IBOutlet weak var lyricsScrollView: ScrollLyricsView!
    @IBOutlet weak var noLyricsLabel: NSTextField!
    
    @objc dynamic var isTracking = true
    
    override func awakeFromNib() {
        view.window?.do {
            $0.titlebarAppearsTransparent = true
            $0.titleVisibility = .hidden
            $0.styleMask.insert(.borderless)
        }
        let accessory = NSStoryboard.main!.instantiateController(withIdentifier: .LyricsHUDAccessory) as! NSTitlebarAccessoryViewController
        accessory.layoutAttribute = .right
        view.window?.addTitlebarAccessoryViewController(accessory)
        
        dragNDropView.dragDelegate = self
        lyricsScrollView.delegate = self
        lyricsScrollView.setupTextContents(lyrics: AppController.shared.currentLyrics)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
        nc.addObserver(self, selector: #selector(handleLyricsChange), name: .currentLyricsChange, object: nil)
        nc.addObserver(self, selector: #selector(handleScrollViewWillStartScroll), name: NSScrollView.willStartLiveScrollNotification, object: lyricsScrollView)
    }
    
    override func viewWillAppear() {
        noLyricsLabel.isHidden = AppController.shared.currentLyrics != nil
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func doubleClickLyricsLine(at position: TimeInterval) {
        let pos = position - (AppController.shared.currentLyrics?.timeDelay ?? 0)
        MusicPlayerManager.shared.player?.playerPosition = pos
        isTracking = true
    }
    
    func scrollWheelDidStartScroll() {
        isTracking = false
    }
    
    func scrollWheelDidEndScroll() {}
    
    // MARK: - Handler
    
    @objc func handleLyricsChange() {
        DispatchQueue.main.async {
            let newLyrics = AppController.shared.currentLyrics
            self.lyricsScrollView.setupTextContents(lyrics: newLyrics)
            self.noLyricsLabel.isHidden = newLyrics != nil
        }
    }
    
    @objc func handleLyricsDisplay() {
        guard var pos = MusicPlayerManager.shared.player?.playerPosition else {
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
    
    @objc func handleScrollViewWillStartScroll(_ n: Notification) {
        isTracking = false
    }
    
    // MARK: DragNDropDelegate
    
    func dragFinished(content: String) {
        AppController.shared.importLyrics(content)
    }
    
}

class LyricsHUDAccessoryViewController: NSTitlebarAccessoryViewController {
    
    @IBAction func lockAction(_ sender: NSButton) {
        if sender.state == .on {
            view.window?.level = .modalPanel
        } else {
            view.window?.level = .normal
        }
    }
    
}
