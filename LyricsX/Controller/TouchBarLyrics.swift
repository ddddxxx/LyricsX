//
//  TouchBarLyrics.swift
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
import LyricsProvider
import OpenCC

#if IS_FOR_MAS
#else

@available(OSX 10.12.2, *)
class TouchBarLyrics: NSObject, NSTouchBarDelegate {
    
    let touchBar = NSTouchBar()
    let systemTrayItem = NSCustomTouchBarItem(identifier: .systemTrayItem)
    
    var lyricsTextField = NSTextField(labelWithString: "")
    
    var screenLyrics = ""
    
    override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.lyrics]
        
        systemTrayItem.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(presentTouchBar))
        self.systemTrayItem.setSystemTrayPresent(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .currentLyricsChange, object: nil)
        
        lyricsTextField.bind(\.tfProgressColor, withUnmatchedDefaultName: .DesktopLyricsProgressColor)
    }
    
    deinit {
        self.systemTrayItem.setSystemTrayPresent(false)
    }
    
    @objc private func presentTouchBar() {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
    }
    
    @objc func handleLyricsDisplay() {
        guard let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
                DispatchQueue.main.async {
                    self.lyricsTextField.stringValue = ""
                    self.lyricsTextField.tf_removeProgressAnimation()
                }
                return
        }
        let line = lyrics.lines[index]
        var lyricsContent = line.content
        if let converter = ChineseConverter.shared {
            lyricsContent = converter.convert(lyricsContent)
        }
        DispatchQueue.main.async {
            self.lyricsTextField.stringValue = lyricsContent
            if let timetag = line.attachments.timetag,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = line.lyrics?.adjustedTimeDelay ?? 0
                let progress = timetag.tags.map { ($0.timeTag + line.position - timeDelay - position, $0.index) }
                self.lyricsTextField.tf_addProgressAnimation(progress)
            }
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == .lyrics {
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = lyricsTextField
            return item
        } else {
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
extension NSTouchBarItem {
    
    func setSystemTrayPresent(_ isPresent: Bool) {
        if isPresent {
            NSTouchBarItem.addSystemTrayItem(self)
        } else {
            NSTouchBarItem.removeSystemTrayItem(self)
        }
        DFRElementSetControlStripPresenceForIdentifier(identifier, isPresent)
        DFRSystemModalShowsCloseBoxWhenFrontMost(isPresent)
    }
}

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    
    static let lyrics = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.lyrics")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.systemTrayItem")
}

private extension NSTextField {
    
    func rectArrayForAllCharacters() -> [NSRect] {
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedStringValue)
        var containerSize = frame.size
        // the imitated text container clip its content whereas text field does not.
        // expand container size to avoid clipping.
        containerSize.width = .infinity
        let textContainer = NSTextContainer(containerSize: containerSize)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        return stringValue.indices.map { index in
            let range = NSRange(index...index, in: stringValue)
            return layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
        }
    }
}

private extension NSTextField {
    
    func tf_addProgressAnimation(_ progress: [(TimeInterval, Int)]) {
        let progressTextField = NSTextField(labelWithString: stringValue)
        addSubview(progressTextField)
        progressTextField.wantsLayer = true
        progressTextField.bind(\.textColor, to: self, withKeyPath: \.tfProgressColor)
        progressTextField.bind(\.stringValue, to: self, withKeyPath: \.stringValue)
        progressTextField.bind(\.font, to: self, withKeyPath: \.font)
        progressTextField.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        guard let index = progress.index(where: { $0.0 > 0 }) else { return }
        let rectArray = rectArrayForAllCharacters()
        var map = progress.map { ($0.0, rectArray[rectArray.indices.clamp($0.1 - 1)].maxX) }
        if index > 0 {
            let progress = map[index - 1].1 + CGFloat(map[index - 1].0) * (map[index].1 - map[index - 1].1) / CGFloat(map[index].0 - map[index - 1].0)
            map.replaceSubrange(..<index, with: [(0, progress)])
        }
        
        let duration = map.last!.0
        let animation = CAKeyframeAnimation()
        animation.keyTimes = map.map { ($0.0 / duration) as NSNumber }
        animation.values = map.map { $0.1 }
        animation.keyPath = "bounds.size.width"
        animation.duration = duration
        progressTextField.layer?.add(animation, forKey: "inlineProgress")
        
        self.tfProgressTextField?.removeFromSuperview()
        self.tfProgressTextField = progressTextField
    }
    
    func tf_removeProgressAnimation() {
        tfProgressTextField?.removeFromSuperview()
        tfProgressTextField = nil
    }
    
    private static var progressTFToken = 0
    private var tfProgressTextField: NSTextField? {
        get {
            return objc_getAssociatedObject(self, &NSTextField.progressTFToken) as? NSTextField
        }
        set {
            objc_setAssociatedObject(self, &NSTextField.progressTFToken, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var progressColorToken = 0
    @objc dynamic var tfProgressColor: NSColor? {
        get {
            return objc_getAssociatedObject(self, &NSTextField.progressColorToken) as? NSColor
        }
        set {
            objc_setAssociatedObject(self, &NSTextField.progressColorToken, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

#endif
