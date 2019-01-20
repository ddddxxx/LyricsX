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
import DFRPrivate

#if IS_FOR_MAS
#else

@available(OSX 10.12.2, *)
class TouchBarLyrics: NSObject, NSTouchBarDelegate {
    
    let touchBar = NSTouchBar()
    private let systemTrayItem = NSCustomTouchBarItem(identifier: .systemTrayItem)
    
    private var lyricsItem = TouchBarLyricsItem(identifier: .lyrics)
    
    override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.currentPlaying, .fixedSpaceSmall, .lyrics, .flexibleSpace]
        
        systemTrayItem.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(presentTouchBar))
        systemTrayItem.addToSystemTray()
        systemTrayItem.setControlStripPresence(true)
        NSTouchBar.setSystemModalShowsCloseBoxWhenFrontMost(true)
        
        lyricsItem.bind(\.progressColor, withUnmatchedDefaultName: .DesktopLyricsProgressColor)
        
        NSUserNotificationCenter.default.observeNotification(name: NSApplication.didBecomeActiveNotification) { _ in
            self.systemTrayItem.setControlStripPresence(true)
        }
    }
    
    deinit {
        self.systemTrayItem.removeFromSystemTray()
    }
    
    @objc private func presentTouchBar() {
        touchBar.presentAsSystemModal(for: systemTrayItem)
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .lyrics:
            return TouchBarLyricsItem(identifier: identifier)
        case .currentPlaying:
            return TouchBarCurrentPlayingItem(identifier: identifier)
        default:
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
private extension NSTouchBarItem.Identifier {
    
    static let lyrics = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.lyrics")
    static let currentPlaying = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.currentPlaying")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.systemTrayItem")
}

#endif
