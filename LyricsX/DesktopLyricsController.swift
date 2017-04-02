//
//  DesktopLyricsController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SnapKit
import EasyPreference
import OpenCC

class DesktopLyricsWindowController: NSWindowController {
    
    override func windowDidLoad() {
        let visibleFrame = NSScreen.main()!.visibleFrame
        window?.setFrame(visibleFrame, display: true)
        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.ignoresMouseEvents = true
        window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        if Preference[DisableLyricsWhenSreenShot] {
            window?.sharingType = .none
        }
    }
    
}

class DesktopLyricsViewController: NSViewController {
    
    @IBOutlet weak var lyricsView: KaraokeLyricsView!
    @IBOutlet weak var lyricsHeightConstraint: NSLayoutConstraint!
    
    private var chineseConverter: ChineseConverter?
    
    var currentLyricsPosition: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch Preference[ChineseConversionIndex] {
        case 1:
            chineseConverter = ChineseConverter(option: [.simplify])
        case 2:
            chineseConverter = ChineseConverter(option: [.traditionalize])
        default:
            chineseConverter = nil
        }
        
        let dfs = UserDefaults.standard
        let transOpt = [NSValueTransformerNameBindingOption: NSValueTransformerName.keyedUnarchiveFromDataTransformerName]
        lyricsView.bind("fontName", to: dfs, withKeyPath: DesktopLyricsFontName.rawValue, options: nil)
        lyricsView.bind("fontSize", to: dfs, withKeyPath: DesktopLyricsFontSize.rawValue, options: nil)
        lyricsView.bind("textColor", to: dfs, withKeyPath: DesktopLyricsColor.rawValue, options: transOpt)
        lyricsView.bind("shadowColor", to: dfs, withKeyPath: DesktopLyricsShadowColor.rawValue, options: transOpt)
        
        lyricsHeightConstraint.constant = CGFloat(Preference[DesktopLyricsHeighFromDock])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.displayLrc("")
            self.addObserver()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        
        Preference.subscribe(key: DesktopLyricsHeighFromDock) { change in
            self.lyricsHeightConstraint.constant = CGFloat(change.newValue)
        }
        
        Preference.subscribe(key: DesktopLyricsBackgroundColor) { change in
            self.lyricsView.fillColor = change.newValue
        }
        
        Preference.subscribe(key: DesktopLyricsShadowColor) { change in
            self.lyricsView.shadowColor = change.newValue
        }
        
        Preference.subscribe(key: ChineseConversionIndex) { change in
            switch change.newValue {
            case 1:
                self.chineseConverter = ChineseConverter(option: [.simplify])
            case 2:
                self.chineseConverter = ChineseConverter(option: [.traditionalize])
            default:
                self.chineseConverter = nil
            }
        }
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
        if Preference[PreferBilingualLyrics] {
            secondLine = lrc?.translation ?? next?.sentence
        } else {
            secondLine = next?.sentence
        }
        
        displayLrc(firstLine, secondLine: secondLine)
    }
    
    func displayLrc(_ firstLine: String?, secondLine: String? = nil) {
        guard Preference[DesktopLyricsEnabled] else {
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
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
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
    
}
