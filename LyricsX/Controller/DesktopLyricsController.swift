//
//  DesktopLyricsController.swift
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
import SnapKit
import OpenCC

class DesktopLyricsWindowController: NSWindowController {
    
    override func windowDidLoad() {
        if let mainScreen = NSScreen.main() {
            window?.setFrame(mainScreen.visibleFrame, display: true)
        }
        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.ignoresMouseEvents = true
        window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        if defaults[.DisableLyricsWhenSreenShot] {
            window?.sharingType = .none
        }
        
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(updateWindowFrame), name: .NSWorkspaceActiveSpaceDidChange, object: nil)
    }
    
    func updateWindowFrame() {
        guard let mainScreen = NSScreen.main() else {
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
        
        let dfs = UserDefaults.standard
        let transOpt = [NSValueTransformerNameBindingOption: NSValueTransformerName.keyedUnarchiveFromDataTransformerName]
        lyricsView.bind("fontName", to: dfs, withKeyPath: .DesktopLyricsFontName, options: nil)
        lyricsView.bind("fontSize", to: dfs, withKeyPath: .DesktopLyricsFontSize, options: nil)
        lyricsView.bind("textColor", to: dfs, withKeyPath: .DesktopLyricsColor, options: transOpt)
        lyricsView.bind("shadowColor", to: dfs, withKeyPath: .DesktopLyricsShadowColor, options: transOpt)
        lyricsView.bind("fillColor", to: dfs, withKeyPath: .DesktopLyricsBackgroundColor, options: transOpt)
        
        makeConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.displayLrc("")
            self.addObserver()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        
        defaults.addObserver(key: .ChineseConversionIndex, initial: true) { _, new in
            switch new {
            case 1:
                self.chineseConverter = ChineseConverter(option: [.simplify])
            case 2:
                self.chineseConverter = ChineseConverter(option: [.traditionalize])
            default:
                self.chineseConverter = nil
            }
        }
        
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetTopEnabled)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetBottomEnabled)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetLeftEnabled)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetRightEnabled)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetTop)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetBottom)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetLeft)
        defaults.addObserver(self, forKeyPath: .DesktopLyricsInsetRight)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard object as? UserDefaults == defaults else {
            return
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            context.timingFunction = .mystery
            self.makeConstraints()
            self.view.needsLayout = true
            self.view.layoutSubtreeIfNeeded()
            self.view.displayIfNeeded()
        })
    }
    
    func handlePositionChange(_ n: Notification) {
        let lrc = n.userInfo?["lrc"] as? LyricsLine
        let next = n.userInfo?["next"] as? LyricsLine
        
        guard currentLyricsPosition != lrc?.position else {
            return
        }
        
        currentLyricsPosition = lrc?.position ?? 0
        
        let firstLine = lrc?.sentence
        let secondLine: String?
        if defaults[.PreferBilingualLyrics] {
            secondLine = lrc?.translation ?? next?.sentence
        } else {
            secondLine = next?.sentence
        }
        
        displayLrc(firstLine, secondLine: secondLine)
    }
    
    func displayLrc(_ firstLine: String?, secondLine: String? = nil) {
        guard defaults[.DesktopLyricsEnabled] else {
            return
        }
        
        var firstLine = firstLine ?? ""
        var secondLine = secondLine ?? ""
        if let converter = chineseConverter {
            firstLine = converter.convert(firstLine)
            secondLine = converter.convert(secondLine)
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            context.timingFunction = .mystery
            self.lyricsView.firstLine = firstLine
            self.lyricsView.secondLine = secondLine
            self.lyricsView.onAnimation = true
            self.view.needsUpdateConstraints = true
            self.view.needsLayout = true
            self.view.layoutSubtreeIfNeeded()
        }, completionHandler: {
            self.lyricsView.onAnimation = false
            self.view.needsUpdateConstraints = true
            self.view.needsLayout = true
            self.view.layoutSubtreeIfNeeded()
        })
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
