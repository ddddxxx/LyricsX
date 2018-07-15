//
//  KaraokeLyricsController.swift
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
import LyricsProvider
import MusicPlayer
import OpenCC
import SnapKit

class KaraokeLyricsWindowController: NSWindowController {
    
    private var lyricsView = KaraokeLyricsView(frame: .zero)
    
    var defaultObservations: [DefaultsObservation] = []
    var notifications: [NSObjectProtocol] = []
    
    var screen: NSScreen {
        didSet {
            defaults[.DesktopLyricsScreenRect] = screen.frame
            updateWindowFrame()
        }
    }
    
    init() {
        let rect = defaults[.DesktopLyricsScreenRect]
        screen = NSScreen.screens.first { $0.frame.contains(rect) } ?? NSScreen.main!
        let window = NSWindow(contentRect: screen.visibleFrame, styleMask: .borderless, backing: .buffered, defer: true)
        super.init(window: window)
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        window.contentView?.addSubview(lyricsView)
        
        addObserver()
        makeConstraints()
        
        lyricsView.displayLrc("LyricsX")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lyricsView.displayLrc("")
            self.handleLyricsDisplay()
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .currentLyricsChange, object: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addObserver() {
        lyricsView.bind(NSBindingName("textColor"), to: defaults, withDefaultName: .DesktopLyricsColor)
        lyricsView.bind(NSBindingName("shadowColor"), to: defaults, withDefaultName: .DesktopLyricsShadowColor)
        lyricsView.bind(NSBindingName("fillColor"), to: defaults, withDefaultName: .DesktopLyricsBackgroundColor)
        lyricsView.bind(NSBindingName("shouldHideWithMouse"), to: defaults, withDefaultName: .HideLyricsWhenMousePassingBy, options: [.nullPlaceholder: false])
        lyricsView.bind(NSBindingName("isVertical"), to: defaults, withDefaultName: .DesktopLyricsVerticalMode, options: [.nullPlaceholder: false])
        
        let negateOption = [NSBindingOption.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName]
        window?.contentView?.bind(.hidden, to: defaults, withDefaultName: .DesktopLyricsEnabled, options: negateOption)
        
        defaultObservations += [
            defaults.observe(.DisableLyricsWhenSreenShot, options: [.new, .initial]) { [weak self] _, change in
                switch change.newValue {
                case true: self?.window?.sharingType = .none
                case false: self?.window?.sharingType = .readOnly
                }
            },
            defaults.observe(keys: [
                .DesktopLyricsFontName,
                .DesktopLyricsFontSize,
                .DesktopLyricsFontNameFallback
            ], options: [.initial]) { [weak self] in
                self?.lyricsView.font = defaults.desktopLyricsFont
            },
            defaults.observe(keys: [
                .DesktopLyricsInsetTopEnabled,
                .DesktopLyricsInsetBottomEnabled,
                .DesktopLyricsInsetLeftEnabled,
                .DesktopLyricsInsetRightEnabled,
                .DesktopLyricsInsetTop,
                .DesktopLyricsInsetBottom,
                .DesktopLyricsInsetLeft,
                .DesktopLyricsInsetRight
                ], options: []) { [weak self] in
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.2
                        context.allowsImplicitAnimation = true
                        context.timingFunction = .mystery
                        self?.makeConstraints()
                        self?.window?.layoutIfNeeded()
                    })
            }
        ]
        
        // swiftlint:disable:next discarded_notification_center_observer
        notifications += [NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateWindowFrame()
        }]
    }
    
    func updateWindowFrame() {
        let frame = isFullScreen() == true ? screen.frame : screen.visibleFrame
        window?.setFrame(frame, display: false, animate: true)
    }
    
    @objc func handleLyricsDisplay() {
        guard defaults[.DesktopLyricsEnabled],
            !defaults[.DisableLyricsWhenPaused] || AppController.shared.playerManager.player?.playbackState == .playing,
            let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
                DispatchQueue.main.async {
                    self.lyricsView.displayLrc("", secondLine: "")
                }
                return
        }
        
        let lrc = lyrics.lines[index]
        let next = lyrics.lines[(index + 1)...].first { $0.enabled }
        
        var firstLine = lrc.content
        var secondLine: String
        if defaults[.DesktopLyricsOneLineMode] {
            secondLine = ""
        } else if defaults[.PreferBilingualLyrics] {
            secondLine = lrc.attachments.translation() ?? next?.content ?? ""
        } else {
            secondLine = next?.content ?? ""
        }
        
        if let converter = ChineseConverter.shared {
            firstLine = converter.convert(firstLine)
            secondLine = converter.convert(secondLine)
        }
        
        DispatchQueue.main.async {
            self.lyricsView.displayLrc(firstLine, secondLine: secondLine)
            if let upperTextField = self.lyricsView.displayLine1,
                let timetag = lrc.attachments.timetag,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = AppController.shared.currentLyrics?.timeDelay ?? 0
                let progress = timetag.tags.map { ($0.timeTag + lrc.position - timeDelay - position, $0.index) }
                upperTextField.setProgressAnimation(color: self.lyricsView.shadowColor, progress: progress)
            }
        }
    }
    
    private func makeConstraints() {
        lyricsView.snp.remakeConstraints { make in
            let top = defaults[.DesktopLyricsInsetTop]
            let bottom = defaults[.DesktopLyricsInsetBottom]
            let left = defaults[.DesktopLyricsInsetLeft]
            let right = defaults[.DesktopLyricsInsetRight]
            
            switch (defaults[.DesktopLyricsInsetTopEnabled], defaults[.DesktopLyricsInsetBottomEnabled]) {
            case (true, true):
                make.centerY.equalToSuperview().offset(top - bottom)
            case (true, false):
                make.top.equalToSuperview().offset(top)
            case (false, true):
                make.bottom.equalToSuperview().offset(-bottom)
            default:
                make.centerY.equalToSuperview()
            }
            
            switch (defaults[.DesktopLyricsInsetLeftEnabled], defaults[.DesktopLyricsInsetRightEnabled]) {
            case (true, true):
                make.centerX.equalToSuperview().offset(left - right)
            case (true, false):
                make.left.equalToSuperview().offset(left)
            case (false, true):
                make.right.equalToSuperview().offset(-right)
            default:
                make.centerX.equalToSuperview()
            }
        }
    }
    
}

func isFullScreen() -> Bool? {
    guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] else {
        return nil
    }
    for info in windowInfoList where
        info[kCGWindowOwnerName as String] as? String == "Window Server" &&
            info[kCGWindowName as String] as? String == "Menubar" {
                return false
    }
    return true
}
