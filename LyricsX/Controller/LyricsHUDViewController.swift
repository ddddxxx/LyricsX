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
import GenericID
import MusicPlayer

class LyricsHUDViewController: NSViewController, NSWindowDelegate, ScrollLyricsViewDelegate, DragNDropDelegate {
    
    @IBOutlet weak var dragNDropView: DragNDropView!
    @IBOutlet weak var lyricsScrollView: ScrollLyricsView!
    @IBOutlet weak var noLyricsLabel: NSTextField!
    
    @IBOutlet weak var lyricsScrollViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var lyricsScrollViewLeftMargin: NSLayoutConstraint!
    
    @objc dynamic var isTracking = true {
        didSet {
            if !oldValue, isTracking {
                displayLyrics()
            }
        }
    }
    
    private var observations: [NSObjectProtocol] = []
    private var defaltsObservation: DefaultsObservation?
    
    override func awakeFromNib() {
        view.window?.do {
            $0.titlebarAppearsTransparent = true
            $0.titleVisibility = .hidden
            $0.styleMask.insert(.borderless)
            $0.delegate = self
        }
        // swiftlint:disable:next force_cast
        let accessory = NSStoryboard.main!.instantiateController(withIdentifier: .LyricsHUDAccessory) as! NSTitlebarAccessoryViewController
        accessory.layoutAttribute = .right
        view.window?.addTitlebarAccessoryViewController(accessory)
        
        dragNDropView.dragDelegate = self
        lyricsScrollView.delegate = self
        lyricsScrollView.setupTextContents(lyrics: AppController.shared.currentLyrics)
        
        lyricsScrollView.bind(NSBindingName("fontName"), to: defaults, withDefaultName: .LyricsWindowFontName)
        lyricsScrollView.bind(NSBindingName("fontSize"), to: defaults, withDefaultName: .LyricsWindowFontSize)
        lyricsScrollView.bind(NSBindingName("textColor"), to: defaults, withDefaultName: .LyricsWindowTextColor)
        lyricsScrollView.bind(NSBindingName("highlightColor"), to: defaults, withDefaultName: .LyricsWindowHighlightColor)
        
        defaltsObservation = defaults.observe(.LyricsWindowFontSize, options: [.new, .initial]) { [unowned self] _, change in
            let fontSize = CGFloat(change.newValue)
            self.lyricsScrollViewTopMargin.constant = fontSize
            self.lyricsScrollViewLeftMargin.constant = fontSize
            self.displayLyrics(animation: false)
        }
        
        let nc = NotificationCenter.default
        // swiftlint:disable discarded_notification_center_observer
        observations += [
            nc.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: nil) { [unowned self] _ in self.displayLyrics() },
            nc.addObserver(forName: .currentLyricsChange, object: nil, queue: nil) { [unowned self] _ in self.lyricsChanged() },
            nc.addObserver(forName: NSScrollView.willStartLiveScrollNotification, object: lyricsScrollView, queue: .main) { [unowned self] _ in self.isTracking = false }
        ]
        // swiftlint:enable discarded_notification_center_observer
    }
    
    override func viewWillAppear() {
        noLyricsLabel.isHidden = AppController.shared.currentLyrics != nil
        displayLyrics(animation: false)
    }
    
    deinit {
        observations.forEach(NotificationCenter.default.removeObserver)
    }
    
    // MARK: - Handler
    
    func lyricsChanged() {
        DispatchQueue.main.async {
            let newLyrics = AppController.shared.currentLyrics
            self.lyricsScrollView.setupTextContents(lyrics: newLyrics)
            self.noLyricsLabel.isHidden = newLyrics != nil
            self.displayLyrics(animation: false)
        }
        
    }
    
    func displayLyrics(animation: Bool = true) {
        guard var pos = AppController.shared.playerManager.player?.playerPosition else {
            return
        }
        pos += AppController.shared.currentLyrics?.timeDelay ?? 0
        lyricsScrollView.highlight(position: pos)
        guard isTracking else {
            return
        }
        if animation {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                context.timingFunction = .mystery
                self.lyricsScrollView.scroll(position: pos)
            })
        } else {
            lyricsScrollView.scroll(position: pos)
        }
    }
    
    // MARK: ScrollLyricsViewDelegate
    
    func doubleClickLyricsLine(at position: TimeInterval) {
        let pos = position - (AppController.shared.currentLyrics?.timeDelay ?? 0)
        AppController.shared.playerManager.player?.playerPosition = pos
        isTracking = true
    }
    
    func scrollWheelDidStartScroll() {
        isTracking = false
    }
    
    func scrollWheelDidEndScroll() {}
    
    // MARK: NSWindowDelegate
    
    func windowDidResize(_ notification: Notification) {
        displayLyrics(animation: false)
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
