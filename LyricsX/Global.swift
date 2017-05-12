//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//
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
import GenericID

let LyricsXGroupIdentifier = "group.ddddxxx.LyricsX"
let LyricsXHelperIdentifier = "ddddxxx.LyricsXHelper"

let defaults = UserDefaults.standard

extension UserDefaults {
    static let group = UserDefaults(suiteName: LyricsXGroupIdentifier)!
}

extension CAMediaTimingFunction {
    static let mystery = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
}

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplayNotification"
let CurrentLyricsChangeNotification = "CurrentLyricsChangeNotification"

extension Notification.Name {
    static var PositionChange = Notification.Name(LyricsShouldDisplayNotification)
    static var LyricsChange = Notification.Name(CurrentLyricsChangeNotification)
}

// MARK: - User Defaults

extension UserDefaults.DefaultKeys {
    
    static let NotifiedUpdateVersion: Key<String?>  = "NotifiedUpdateVersion"
    
    // Menu
    static let DesktopLyricsEnabled: Key<Bool>  = "DesktopLyricsEnabled"
    static let MenuBarLyricsEnabled: Key<Bool>  = "MenuBarLyricsEnabled"
    
    // General
    static let PreferredPlayerIndex: Key<Int>       = "PreferredPlayerIndex"
    static let LaunchAndQuitWithPlayer: Key<Bool>   = "LaunchAndQuitWithPlayer"
    
    static let LyricsSavingPathPopUpIndex: Key<Int>         = "LyricsSavingPathPopUpIndex"
    static let LyricsCustomSavingPathBookmark: Key<Data?>   = "LyricsCustomSavingPathBookmark"
    
    static let PreferBilingualLyrics: Key<Bool>         = "PreferBilingualLyrics"
    static let ChineseConversionIndex: Key<Int>         = "ChineseConversionIndex"
    
    static let CombinedMenubarLyrics: Key<Bool>         = "CombinedMenubarLyrics"
    
    static let DisableLyricsWhenPaused: Key<Bool>       = "DisableLyricsWhenPaused"
    static let DisableLyricsWhenSreenShot: Key<Bool>    = "DisableLyricsWhenSreenShot"
    
    // Display
    static let DesktopLyricsHeighFromDock: Key<Int>     = "DesktopLyricsHeighFromDock"
    static let DesktopLyricsFontName: Key<String?>      = "DesktopLyricsFontName"
    static let DesktopLyricsFontSize: Key<Int>          = "DesktopLyricsFontSize"
    
    static let DesktopLyricsColor: Key<NSColor>             = "DesktopLyricsColor"
    static let DesktopLyricsShadowColor: Key<NSColor>       = "DesktopLyricsShadowColor"
    static let DesktopLyricsBackgroundColor: Key<NSColor>   = "DesktopLyricsBackgroundColor"
    
    static let DisplayLyricsWithTag: Key<Bool>      = "DisplayLyricsWithTag"
    
    // Filter
    static let LyricsFilterEnabled: Key<Bool>       = "LyricsFilterEnabled"
    static let LyricsSmartFilterEnabled: Key<Bool>  = "LyricsSmartFilterEnabled"
    static let LyricsDirectFilterKey: Key<[String]> = "LyricsDirectFilterKey"
    static let LyricsColonFilterKey: Key<[String]>  = "LyricsColonFilterKey"
}
