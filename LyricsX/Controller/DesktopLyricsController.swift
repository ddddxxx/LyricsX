//
//  DesktopLyricsController.swift
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
import SnapKit
import OpenCC
import LyricsProvider

class DesktopLyricsWindowController: NSWindowController {
    
    var disableLyricsWhenSreenShotObservation: UserDefaults.KeyValueObservation?
    
    override func windowDidLoad() {
        window?.do {
            if let mainScreen = NSScreen.main {
                $0.setFrame(mainScreen.visibleFrame, display: true)
            }
            $0.backgroundColor = .clear
            $0.isOpaque = false
            $0.ignoresMouseEvents = true
            $0.level = .floating
        }
        
        disableLyricsWhenSreenShotObservation = defaults.observe(.DisableLyricsWhenSreenShot, options: [.new, .initial]) { [weak self] defaults, change in
            switch change.newValue {
            case true?: self?.window?.sharingType = .none
            case false?: self?.window?.sharingType = .readOnly
            case nil: break
            }
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(updateWindowFrame), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
    }
    
    @objc func updateWindowFrame() {
        guard let mainScreen = NSScreen.main else {
            return
        }
        let frame = isFullScreen() == true ? mainScreen.frame : mainScreen.visibleFrame
        window?.setFrame(frame, display: true, animate: true)
    }
    
    func isFullScreen() -> Bool? {
        guard let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        for info in windowInfoList {
            if info[kCGWindowOwnerName as String] as? String == "Window Server",
                info[kCGWindowName as String] as? String == "Menubar" {
                return false
            }
        }
        return true
    }
}

class DesktopLyricsViewController: NSViewController {
    
    @IBOutlet weak var lyricsView: KaraokeLyricsView!
    
    private var chineseConverter: ChineseConverter?
    
    var currentLyricsPosition: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        makeConstraints()
        
        lyricsView.displayLrc("LyricsX")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lyricsView.displayLrc("")
            NotificationCenter.default.addObserver(self, selector: #selector(self.handlePositionChange), name: .PositionChange, object: nil)
        }
    }
    
    var lyricsViewObservations: [UserDefaults.KeyValueObservation] = []
    var chineseConverterObservation: UserDefaults.KeyValueObservation?
    var lyricsInsetObservation: UserDefaults.KeyValueObservation?
    
    private func addObserver() {
        
        /*
        let transOpt = [NSBindingOption.valueTransformerName: NSValueTransformerName.keyedUnarchiveFromDataTransformerName]
        lyricsView.bind(NSBindingName("fontName"), to: defaults, withKeyPath: .DesktopLyricsFontName)
        lyricsView.bind(NSBindingName("fontSize"), to: defaults, withKeyPath: .DesktopLyricsFontSize)
        lyricsView.bind(NSBindingName("textColor"), to: defaults, withKeyPath: .DesktopLyricsColor, options: transOpt)
        lyricsView.bind(NSBindingName("shadowColor"), to: defaults, withKeyPath: .DesktopLyricsShadowColor, options: transOpt)
        lyricsView.bind(NSBindingName("fillColor"), to: defaults, withKeyPath: .DesktopLyricsBackgroundColor, options: transOpt)
        lyricsView.bind(NSBindingName("shouldHideWithMouse"), to: defaults, withKeyPath: .HideLyricsWhenMousePassingBy)
         */
        
        // FIXME: cocoa binding broken.
        lyricsViewObservations += [
            defaults.observe(.DesktopLyricsFontName, options: [.new]) { [weak self] _, change in
                if let fontName = change.newValue {
                    self?.lyricsView.fontName = fontName
                }
            },
            defaults.observe(.DesktopLyricsFontSize, options: [.new]) { [weak self] _, change in
                if let fontSize = change.newValue {
                    self?.lyricsView.fontSize = fontSize
                }
            },
            defaults.observe(.DesktopLyricsColor, options: [.new]) { [weak self] _, change in
                if let textColor = change.newValue {
                    self?.lyricsView.textColor = textColor
                }
            },
            defaults.observe(.DesktopLyricsShadowColor, options: [.new]) { [weak self] _, change in
                if let shadowColor = change.newValue {
                    self?.lyricsView.shadowColor = shadowColor
                }
            },
            defaults.observe(.DesktopLyricsBackgroundColor, options: [.new]) { [weak self] _, change in
                if let fillColor = change.newValue {
                    self?.lyricsView.fillColor = fillColor
                }
            },
            defaults.observe(.HideLyricsWhenMousePassingBy, options: [.new]) { [weak self] _, change in
                if let shouldHideWithMouse = change.newValue {
                    self?.lyricsView.shouldHideWithMouse = shouldHideWithMouse
                }
            },
        ]
        
        chineseConverterObservation = defaults.observe(.ChineseConversionIndex, options: [.new]) { [weak self] _, change in
            switch change.newValue {
            case 1?:
                self?.chineseConverter = ChineseConverter(option: [.simplify])
            case 2?:
                self?.chineseConverter = ChineseConverter(option: [.traditionalize])
            default:
                self?.chineseConverter = nil
            }
        }
        
        lyricsInsetObservation = defaults.observe(keys: [
            .DesktopLyricsInsetTopEnabled,
            .DesktopLyricsInsetBottomEnabled,
            .DesktopLyricsInsetLeftEnabled,
            .DesktopLyricsInsetRightEnabled,
            .DesktopLyricsInsetTop,
            .DesktopLyricsInsetBottom,
            .DesktopLyricsInsetLeft,
            .DesktopLyricsInsetRight,
            ], options: []) { [weak self] in
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    context.allowsImplicitAnimation = true
                    context.timingFunction = .mystery
                    self?.makeConstraints()
                    self?.view.layoutSubtreeIfNeeded()
                })
        }
    }
    
    @objc func handlePositionChange(_ n: Notification) {
        guard defaults[.DesktopLyricsEnabled] else {
            return
        }
        
        let lrc = n.userInfo?["lrc"] as? LyricsLine
        let next = n.userInfo?["next"] as? LyricsLine
        
        guard currentLyricsPosition != lrc?.position else {
            return
        }
        currentLyricsPosition = lrc?.position ?? 0
        
        var firstLine = lrc?.content ?? ""
        var secondLine: String
        if defaults[.DesktopLyricsOneLineMode] {
            secondLine = ""
        } else if defaults[.PreferBilingualLyrics] {
            secondLine = lrc?.translation ?? next?.content ?? ""
        } else {
            secondLine = next?.content ?? ""
        }
        
        if let converter = chineseConverter {
            firstLine = converter.convert(firstLine)
            secondLine = converter.convert(secondLine)
        }
        
        lyricsView.displayLrc(firstLine, secondLine: secondLine)
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
