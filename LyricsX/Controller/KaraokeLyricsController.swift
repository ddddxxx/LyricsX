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
    
    static private let windowFrame = NSWindow.FrameAutosaveName("KaraokeWindow")
    
    private var lyricsView = KaraokeLyricsView(frame: .zero)
    
    init() {
        let window = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isOpaque = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.setFrameUsingName(KaraokeLyricsWindowController.windowFrame, force: true)
        super.init(window: window)
        
        window.contentView?.addSubview(lyricsView)
        
        addObserver()
        makeConstraints()
        
        updateWindowFrame(animate: false)
        
        lyricsView.displayLrc("LyricsX")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lyricsView.displayLrc("")
            self.handleLyricsDisplay()
            self.observeNotification(name: .lyricsShouldDisplay) { [unowned self] _ in
                self.handleLyricsDisplay()
            }
            self.observeNotification(name: .currentLyricsChange) { [unowned self] _ in
                self.handleLyricsDisplay()
            }
            self.observeDefaults(keys: [.PreferBilingualLyrics, .DesktopLyricsOneLineMode]) { [unowned self] in
                self.handleLyricsDisplay()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addObserver() {
        lyricsView.bind(\.textColor, withDefaultName: .DesktopLyricsColor)
        lyricsView.bind(\.progressColor, withDefaultName: .DesktopLyricsProgressColor)
        lyricsView.bind(\.shadowColor, withDefaultName: .DesktopLyricsShadowColor)
        lyricsView.bind(\.backgroundColor, withDefaultName: .DesktopLyricsBackgroundColor)
        lyricsView.bind(\.isVertical, withDefaultName: .DesktopLyricsVerticalMode, options: [.nullPlaceholder: false])
        lyricsView.bind(\.drawFurigana, withDefaultName: .DesktopLyricsEnableFurigana)
        
        let negateOption = [NSBindingOption.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName]
        window?.contentView?.bind(.hidden, withDefaultName: .DesktopLyricsEnabled, options: negateOption)
        
        observeDefaults(key: .DisableLyricsWhenSreenShot, options: [.new, .initial]) { [unowned self] _, change in
            self.window?.sharingType = change.newValue ? .none : .readOnly
        }
        observeDefaults(keys: [
            .HideLyricsWhenMousePassingBy,
            .DesktopLyricsDraggable
        ], options: [.initial]) {
            self.lyricsView.shouldHideWithMouse = defaults[.HideLyricsWhenMousePassingBy] && !defaults[.DesktopLyricsDraggable]
        }
        observeDefaults(keys: [
            .DesktopLyricsFontName,
            .DesktopLyricsFontSize,
            .DesktopLyricsFontNameFallback
        ], options: [.initial]) { [unowned self] in
            self.lyricsView.font = defaults.desktopLyricsFont
        }
        
        observeNotification(name: NSApplication.didChangeScreenParametersNotification, queue: .main) { [unowned self] _ in
            self.updateWindowFrame(animate: true)
        }
        observeNotification(center: workspaceNC, name: NSWorkspace.activeSpaceDidChangeNotification, queue: .main) { [unowned self] _ in
            self.updateWindowFrame(animate: true)
        }
    }
    
    private func updateWindowFrame(toScreen: NSScreen? = nil, animate: Bool) {
        let screen = toScreen ?? window?.screen ?? NSScreen.screens[0]
        let frame = screen.isFullScreen ? screen.frame : screen.visibleFrame
        window?.setFrame(frame, display: false, animate: animate)
        window?.saveFrame(usingName: KaraokeLyricsWindowController.windowFrame)
    }
    
    @objc private func handleLyricsDisplay() {
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
        
        let languageCode = lyrics.metadata.translationLanguages.first
        
        var firstLine = lrc.content
        var secondLine: String
        var secondLineIsTranslation = false
        if defaults[.DesktopLyricsOneLineMode] {
            secondLine = ""
        } else if defaults[.PreferBilingualLyrics],
            let translation = lrc.attachments.translation(languageCode: languageCode) {
            secondLine = translation
            secondLineIsTranslation = true
        } else {
            secondLine = next?.content ?? ""
        }
        
        if let converter = ChineseConverter.shared {
            if lyrics.metadata.language?.hasPrefix("zh") == true {
                firstLine = converter.convert(firstLine)
                if !secondLineIsTranslation {
                    secondLine = converter.convert(secondLine)
                }
            }
            if languageCode?.hasPrefix("zh") == true {
                secondLine = converter.convert(secondLine)
            }
        }
        
        DispatchQueue.main.async {
            self.lyricsView.displayLrc(firstLine, secondLine: secondLine)
            if let upperTextField = self.lyricsView.displayLine1,
                let timetag = lrc.attachments.timetag,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = AppController.shared.currentLyrics?.adjustedTimeDelay ?? 0
                let progress = timetag.tags.map { ($0.timeTag + lrc.position - timeDelay - position, $0.index) }
                upperTextField.setProgressAnimation(color: self.lyricsView.progressColor, progress: progress)
            }
        }
    }
    
    private func makeConstraints() {
        lyricsView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview().safeMultipliedBy(defaults[.DesktopLyricsXPositionFactor] * 2).priority(.low)
            make.centerY.equalToSuperview().safeMultipliedBy(defaults[.DesktopLyricsYPositionFactor] * 2).priority(.low)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: Dragging
    
    private var vecToCenter: CGVector?
    
    override func mouseDown(with event: NSEvent) {
        let location = lyricsView.convert(event.locationInWindow, from: nil)
        vecToCenter = CGVector(from: location, to: lyricsView.bounds.center)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard defaults[.DesktopLyricsDraggable],
            let vecToCenter = vecToCenter,
            let window = window else {
            return
        }
        let bounds = window.frame
        var center = event.locationInWindow + vecToCenter
        let centerInScreen = window.convertToScreen(CGRect(origin: center, size: .zero)).origin
        if let screen = NSScreen.screens.first(where: { $0.frame.contains(centerInScreen) }),
            screen != window.screen {
            updateWindowFrame(toScreen: screen, animate: false)
            center = window.convertFromScreen(CGRect(origin: centerInScreen, size: .zero)).origin
            return
        }
        
        var xFactor = (center.x / bounds.width).clamped(to: 0...1)
        var yFactor = (1 - center.y / bounds.height).clamped(to: 0...1)
        if abs(center.x - bounds.width / 2) < 8 {
            xFactor = 0.5
        }
        if abs(center.y - bounds.height / 2) < 8 {
            yFactor = 0.5
        }
        defaults[.DesktopLyricsXPositionFactor] = xFactor
        defaults[.DesktopLyricsYPositionFactor] = yFactor
        makeConstraints()
        window.layoutIfNeeded()
    }
    
}

private extension NSScreen {
    
    var isFullScreen: Bool {
        guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] else {
            return false
        }
        return !windowInfoList.contains { info in
            guard info[kCGWindowOwnerName as String] as? String == "Window Server",
                info[kCGWindowName as String] as? String == "Menubar",
                let boundsDict = info[kCGWindowBounds as String] as? NSDictionary as CFDictionary?,
                let bounds = CGRect(dictionaryRepresentation: boundsDict) else {
                    return false
            }
            return frame.contains(bounds)
        }
    }
}

private extension ConstraintMakerEditable {
    
    @discardableResult
    func safeMultipliedBy(_ amount: ConstraintMultiplierTarget) -> ConstraintMakerEditable {
        var factor = amount.constraintMultiplierTargetValue
        if factor.isZero {
            factor = .leastNonzeroMagnitude
        }
        return multipliedBy(factor)
    }
}
