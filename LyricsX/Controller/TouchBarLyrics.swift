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
    
    private var lyricsItem = TouchBarLyricsItem(identifier: .lyrics)
    
    override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.flexibleSpace, .lyrics, .flexibleSpace]
        
        systemTrayItem.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(presentTouchBar))
        systemTrayItem.addSystemTray()
        DFRElementSetControlStripPresenceForIdentifier(systemTrayItem.identifier, true)
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        lyricsItem.bind(\.progressColor, withUnmatchedDefaultName: .DesktopLyricsProgressColor)
        
        let nc = NSUserNotificationCenter.default
        nc.observeNotification(name: NSApplication.didBecomeActiveNotification) { _ in
            DFRElementSetControlStripPresenceForIdentifier(self.systemTrayItem.identifier, false)
        }
        nc.observeNotification(name: NSApplication.didResignActiveNotification) { _ in
            DFRElementSetControlStripPresenceForIdentifier(self.systemTrayItem.identifier, true)
        }
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
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .lyrics:
            return TouchBarLyricsItem(identifier: identifier)
        default:
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
