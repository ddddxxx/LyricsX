//
//  LyricsHUDViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import CombineX
import Crashlytics
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
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        
        lyricsScrollView.bind(\.fontName, withDefaultName: .LyricsWindowFontName)
        lyricsScrollView.bind(\.fontSize, withUnmatchedDefaultName: .LyricsWindowFontSize)
        lyricsScrollView.bind(\.textColor, withDefaultName: .LyricsWindowTextColor)
        lyricsScrollView.bind(\.highlightColor, withDefaultName: .LyricsWindowHighlightColor)
        
        observeDefaults(key: .LyricsWindowFontSize, options: [.new, .initial]) { [unowned self] _, change in
            let fontSize = CGFloat(change.newValue)
            self.lyricsScrollViewTopMargin.constant = fontSize
            self.lyricsScrollViewLeftMargin.constant = fontSize
            self.displayLyrics(animation: false)
        }
        
        AppController.shared.$currentLyrics
            .signal()
            .receive(on: DispatchQueue.main.cx)
            .invoke(LyricsHUDViewController.lyricsChanged, weaklyOn: self)
            .store(in: &cancelBag)
        AppController.shared.$currentLineIndex
            .receive(on: DispatchQueue.main.cx)
            .sink { [unowned self] _ in
                self.displayLyrics()
            }.store(in: &cancelBag)
        
        observeNotification(name: NSScrollView.willStartLiveScrollNotification,
                            object: lyricsScrollView,
                            queue: .main) { [unowned self] _ in self.isTracking = false }
        
        Answers.logCustomEvent(withName: "Show Lyrics Window")
    }
    
    override func viewWillAppear() {
        noLyricsLabel.isHidden = AppController.shared.currentLyrics != nil
        displayLyrics(animation: false)
    }
    
    // MARK: - Handler
    
    private func lyricsChanged() {
        DispatchQueue.main.async {
            let newLyrics = AppController.shared.currentLyrics
            self.lyricsScrollView.setupTextContents(lyrics: newLyrics)
            self.noLyricsLabel.isHidden = newLyrics != nil
            self.displayLyrics(animation: false)
        }
    }
    
    private func displayLyrics(animation: Bool = true) {
        var pos = selectedPlayer.playbackTime
        pos += AppController.shared.currentLyrics?.adjustedTimeDelay ?? 0
        lyricsScrollView.highlight(position: pos)
        guard isTracking else {
            return
        }
        if animation {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                context.timingFunction = .swiftOut
                self.lyricsScrollView.scroll(position: pos)
            }
        } else {
            lyricsScrollView.scroll(position: pos)
        }
    }
    
    // MARK: ScrollLyricsViewDelegate
    
    func doubleClickLyricsLine(at position: TimeInterval) {
        let pos = position - (AppController.shared.currentLyrics?.adjustedTimeDelay ?? 0)
        selectedPlayer.playbackTime = pos
        isTracking = true
        Answers.logCustomEvent(withName: "Seek to Lyrics Line")
    }
    
    func scrollWheelDidStartScroll() {
        isTracking = false
    }
    
    func scrollWheelDidEndScroll() {}
    
    // MARK: NSWindowDelegate
    
    func windowDidResize(_ notification: Notification) {
        DispatchQueue.main.async {
            self.displayLyrics(animation: false)
        }
    }
    
    // MARK: DragNDropDelegate
    
    func dragFinished(content: String) {
        do {
            try AppController.shared.importLyrics(content)
        } catch {
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: view.window!)
        }
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
