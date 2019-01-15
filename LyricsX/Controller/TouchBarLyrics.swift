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
import TouchBarHelper

#if IS_FOR_MAS
#else

@available(OSX 10.12.2, *)
class TouchBarLyrics: NSObject, NSTouchBarDelegate {
    
    let touchBar = NSTouchBar()
    private let systemTrayItem = NSCustomTouchBarItem(identifier: .systemTrayItem)
    
    private var lyricsTextField = KaraokeLabel(labelWithString: "")
    
    @objc dynamic var progressColor = #colorLiteral(red: 0, green: 1, blue: 0.8333333333, alpha: 1)
    
    override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.lyrics]
        
        systemTrayItem.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(presentTouchBar))
        systemTrayItem.addSystemTray()
        DFRElementSetControlStripPresenceForIdentifier(systemTrayItem.identifier, true)
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .lyricsShouldDisplay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleLyricsDisplay), name: .currentLyricsChange, object: nil)
        
        bind(\.progressColor, withUnmatchedDefaultName: .DesktopLyricsProgressColor)
    }
    
    deinit {
        self.systemTrayItem.removeSystemTray()
    }
    
    @objc private func presentTouchBar() {
        if #available(OSX 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
        }
    }
    
    @objc private func handleLyricsDisplay() {
        guard let lyrics = AppController.shared.currentLyrics,
            let index = AppController.shared.currentLineIndex else {
                DispatchQueue.main.async {
                    self.lyricsTextField.stringValue = ""
                    self.lyricsTextField.removeProgressAnimation()
                }
                return
        }
        let line = lyrics.lines[index]
        var lyricsContent = line.content
        if let converter = ChineseConverter.shared,
            lyrics.metadata.language?.hasPrefix("zh") == true {
            lyricsContent = converter.convert(lyricsContent)
        }
        DispatchQueue.main.async {
            self.lyricsTextField.stringValue = lyricsContent
            if let timetag = line.attachments.timetag,
                let position = AppController.shared.playerManager.player?.playerPosition {
                let timeDelay = line.lyrics?.adjustedTimeDelay ?? 0
                let progress = timetag.tags.map { ($0.timeTag + line.position - timeDelay - position, $0.index) }
                self.lyricsTextField.setProgressAnimation(color: self.progressColor, progress: progress)
            }
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == .lyrics {
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view.addSubview(lyricsTextField)
            lyricsTextField.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                // For some reason the left edge get clipped without the offset.
                make.left.equalToSuperview().offset(4)
            }
            return item
        } else {
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
private extension NSTouchBarItem.Identifier {
    
    static let lyrics = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.lyrics")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.systemTrayItem")
}

#endif
