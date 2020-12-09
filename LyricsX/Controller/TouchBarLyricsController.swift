//
//  TouchBarLyrics.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import LyricsCore
import TouchBarHelper
import OpenCC

@available(OSX 10.12.2, *)
class TouchBarLyricsController: TouchBarSystemModalController {
    
    static var shared: TouchBarLyricsController?
    
    private var lyricsItem = TouchBarLyricsItem(identifier: .lyrics)
    
    override func touchBarDidLoad() {
        touchBar?.defaultItemIdentifiers = [.currentArtwork, .fixedSpaceSmall, .playbackControl, .fixedSpaceSmall, .lyrics, .flexibleSpace, .otherItemsProxy]
        touchBar?.customizationIdentifier = .main
        touchBar?.customizationAllowedItemIdentifiers = [.currentArtwork, .playbackControl, .lyrics, .fixedSpaceSmall, .fixedSpaceLarge, .flexibleSpace, .otherItemsProxy]
        
        systemTrayItem = NSCustomTouchBarItem(identifier: .systemTrayItem)
        systemTrayItem?.view = NSButton(image: #imageLiteral(resourceName: "status_bar_icon"), target: self, action: #selector(present))
        
        lyricsItem.bind(\.progressColor, withUnmatchedDefaultName: .desktopLyricsProgressColor)
        
        observeNotification(name: NSApplication.willBecomeActiveNotification) { [weak self] _ in
            guard let self = self else { return }
            self.removeFromControlStrip()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                NSApp.touchBar = self.touchBar
            }
        }
        
        observeNotification(name: NSApplication.didResignActiveNotification) { [weak self] _ in
            guard let self = self else { return }
            NSApp.touchBar = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.showInControlStrip()
            }
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .lyrics:
            return lyricsItem
        case .playbackControl:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.viewController = TouchBarPlaybackControlViewController()
            item.customizationLabel = "Playback Control"
            return item
        case .currentArtwork:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.viewController = TouchBarArtworkViewController()
            item.customizationLabel = "Artwork"
            return item
        default:
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
private extension NSTouchBarItem.Identifier {
    
    static let lyrics = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.lyrics")
    static let currentArtwork = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.currentArtwork")
    static let playbackControl = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.playbackControl")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.LyricsX.touchBar.systemTrayItem")
}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static let main = NSTouchBar.CustomizationIdentifier("ddddxxx.LyricsX.touchBar.customization.main")
}
