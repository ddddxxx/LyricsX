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
import MusicPlayer

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
    
    var currentLineIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        makeConstraints()
        
        lyricsView.displayLrc("LyricsX")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lyricsView.displayLrc("")
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .currentLyricsChange, object: nil)
        }
    }
    
    var lyricsViewObservations: [UserDefaults.KeyValueObservation] = []
    var chineseConverterObservation: UserDefaults.KeyValueObservation?
    var lyricsInsetObservation: UserDefaults.KeyValueObservation?
    
    private func addObserver() {
        
        let transOpt = [NSBindingOption.valueTransformerName: NSValueTransformerName.keyedUnarchiveFromDataTransformerName]
        lyricsView.bind(NSBindingName("fontName"), to: defaults, withKeyPath: .DesktopLyricsFontName)
        lyricsView.bind(NSBindingName("fontSize"), to: defaults, withKeyPath: .DesktopLyricsFontSize)
        lyricsView.bind(NSBindingName("textColor"), to: defaults, withKeyPath: .DesktopLyricsColor, options: transOpt)
        lyricsView.bind(NSBindingName("shadowColor"), to: defaults, withKeyPath: .DesktopLyricsShadowColor, options: transOpt)
        lyricsView.bind(NSBindingName("fillColor"), to: defaults, withKeyPath: .DesktopLyricsBackgroundColor, options: transOpt)
        lyricsView.bind(NSBindingName("shouldHideWithMouse"), to: defaults, withKeyPath: .HideLyricsWhenMousePassingBy)
        
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
    
    @objc func handleLyricsDisplay() {
        guard defaults[.DesktopLyricsEnabled],
            !defaults[.DisableLyricsWhenPaused] || AppController.shared.playerManager.player?.playbackState == .playing,
            let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
                currentLineIndex = nil
                DispatchQueue.main.async {
                    self.lyricsView.displayLrc("", secondLine: "")
                }
                return
        }
        guard currentLineIndex != index else {
            return
        }
        currentLineIndex = index
        
        let lrc = lyrics.lines[index]
        let next = lyrics.lines[(index+1)...].first { $0.enabled }
        
        var firstLine = lrc.content
        var secondLine: String
        if defaults[.DesktopLyricsOneLineMode] {
            secondLine = ""
        } else if defaults[.PreferBilingualLyrics] {
            secondLine = lrc.translation ?? next?.content ?? ""
        } else {
            secondLine = next?.content ?? ""
        }
        
        if let converter = chineseConverter {
            firstLine = converter.convert(firstLine)
            secondLine = converter.convert(secondLine)
        }
        
        DispatchQueue.main.async {
            self.lyricsView.displayLrc(firstLine, secondLine: secondLine)
            if let upperTextField = self.lyricsView.displayLine1,
                let timeline = lrc.attachments[.timetag] as? LyricsLineAttachmentTimeLine,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = AppController.shared.currentLyrics?.timeDelay ?? 0
                let rectArray = upperTextField.rectArray
                
                var map = timeline.tags.map { tag -> (TimeInterval, CGFloat) in
                    let dt = tag.timeTag + lrc.position - timeDelay - position
                    let progress = tag.index == 0 ? 0 : rectArray[min(tag.index, rectArray.count) - 1].maxX
                    return (dt, progress)
                }
                guard let i = map.index(where: { $0.0 > 0 }) else {
                    upperTextField.dyeRect.frame = upperTextField.bounds
                    return
                }
                if i > 0 {
                    let progress = map[i-1].1 + CGFloat(map[i-1].0) * (map[i].1 - map[i-1].1) / CGFloat(map[i].0 - map[i-1].0)
                    map.replaceSubrange(..<i, with: [(0, progress)])
                }
                if let duration = timeline.duration {
                    let progress = rectArray.last!.maxX
                    let dt = duration + lrc.position - timeDelay - position
                    if dt > map.last!.0 {
                        map.append((dt, progress))
                    }
                }
                let duration = map.last!.0
                let animation = CAKeyframeAnimation()
                animation.keyTimes = map.map { ($0.0 / duration) as NSNumber }
                animation.values = map.map { $0.1 }
                animation.keyPath = "bounds.size.width"
                animation.duration = duration
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                upperTextField.dyeRect.layer?.add(animation, forKey: "inlineProgress")
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
