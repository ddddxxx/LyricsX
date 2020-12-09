//
//  GlobalConst.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import CXShim
import GenericID
import MusicPlayer

typealias ObservableObject = CombineX.ObservableObject
typealias Published = CombineX.Published

let fontNameFallbackCountMax = 1
// 7 days. after this period of time since the app built, the app is not considered as "in review".
let masReviewPeriodLimit: TimeInterval = 60 * 60 * 24 * 7

// NOTE: to build your own product, you need to replace the team identifier to yours
// and do the same thing in LyricsXHelper
let lyricsXGroupIdentifier = "3665V726AE.group.ddddxxx.LyricsX"
let lyricsXHelperIdentifier = "ddddxxx.LyricsXHelper"
let lyricsXErrorDomain = "ddddxxx.LyricsX"

let crowdinProjectURL = URL(string: "https://crowdin.com/project/lyricsx")!

let defaults = UserDefaults.standard
let groupDefaults = UserDefaults(suiteName: lyricsXGroupIdentifier)!
let defaultNC = NotificationCenter.default
let workspaceNC = NSWorkspace.shared.notificationCenter
let selectedPlayer = MusicPlayers.Selected.shared

let isInSandbox = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
let isFromMacAppStore = (try? Bundle.main.appStoreReceiptURL?.checkResourceIsReachable()) == true

extension DispatchQueue {
    static let lyricsDisplay = DispatchQueue(label: "LyricsDisplay")
}

extension CAMediaTimingFunction {
    static let mystery = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
    static let swiftOut = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1)
}

func log(_ message: @autoclosure () -> String, file: String = #file, line: UInt = #line) {
    let fileName = (file as NSString).lastPathComponent
    // Adding prefix to distinguish from ton of AppleEvent error log.
    NSLog("CustomLog:\(fileName):\(line): \(message())")
}

// MARK: - Identifier

extension NSUserInterfaceItemIdentifier {
//    static let WriteToiTunes = NSUserInterfaceItemIdentifier("MainMenu.WriteToiTunes")
//    static let SearchLyrics = NSUserInterfaceItemIdentifier("MainMenu.SearchLyrics")
//    static let LyricsMenu = NSUserInterfaceItemIdentifier("MainMenu.Lyrics")
    
    static let searchResultColumnTitle = NSUserInterfaceItemIdentifier("SearchResult.TableColumn.Title")
    static let searchResultColumnArtist = NSUserInterfaceItemIdentifier("SearchResult.TableColumn.Artist")
    static let searchResultColumnSource = NSUserInterfaceItemIdentifier("SearchResult.TableColumn.Source")
}

extension NSStoryboard.SceneIdentifier {
    static let desktopLyricsWindow = NSStoryboard.SceneIdentifier("DesktopLyricsWindow")
    static let lyricsHUDAccessory = NSStoryboard.SceneIdentifier("LyricsHUDAccessory")
}

// MARK: - User Defaults

extension UserDefaults.DefaultsKeys {
    
    static let notifiedUpdateVersion = Key<String?>("NotifiedUpdateVersion")
    static let noSearchingTrackIds = Key<[String]>("NoSearchingTrackIds")
    static let noSearchingAlbumNames = Key<[String]>("NoSearchingAlbumNames")
    
    // Menu
    static let desktopLyricsEnabled = Key<Bool>("DesktopLyricsEnabled")
    static let menuBarLyricsEnabled = Key<Bool>("MenuBarLyricsEnabled")
    static let touchBarLyricsEnabled = Key<Bool>("TouchBarLyricsEnabled")
    
    // General
    static let preferredPlayerIndex = Key<Int>("PreferredPlayerIndex")
    static let launchAndQuitWithPlayer = Key<Bool>("LaunchAndQuitWithPlayer")
    
    static let lyricsSavingPathPopUpIndex = Key<Int>("LyricsSavingPathPopUpIndex")
    static let lyricsCustomSavingPathBookmark = Key<Data?>("LyricsCustomSavingPathBookmark")
    static let loadLyricsBesideTrack = Key<Bool>("LoadLyricsBesideTrack")
    
    static let selectedLanguage = Key<String?>("SelectedLanguage")
    
    static let strictSearchEnabled = Key<Bool>("StrictSearchEnabled")
    static let preferBilingualLyrics = Key<Bool>("PreferBilingualLyrics")
    static let chineseConversionIndex = Key<Int>("ChineseConversionIndex")
    
    static let combinedMenubarLyrics = Key<Bool>("CombinedMenubarLyrics")
    
    static let hideLyricsWhenMousePassingBy = Key<Bool>("HideLyricsWhenMousePassingBy")
    static let disableLyricsWhenPaused = Key<Bool>("DisableLyricsWhenPaused")
    static let disableLyricsWhenSreenShot = Key<Bool>("DisableLyricsWhenSreenShot")
    
    // Display
    static let desktopLyricsOneLineMode = Key<Bool>("DesktopLyricsOneLineMode")
    static let desktopLyricsVerticalMode = Key<Bool>("DesktopLyricsVerticalMode")
    static let desktopLyricsDraggable = Key<Bool>("DesktopLyricsDraggable")
    
    static let desktopLyricsXPositionFactor = Key<CGFloat>("DesktopLyricsXPositionFactor")
    static let desktopLyricsYPositionFactor = Key<CGFloat>("DesktopLyricsYPositionFactor")
    
    static let desktopLyricsEnableFurigana = Key<Bool>("DesktopLyricsEnableFurigana")
    
    static let desktopLyricsFontName = Key<String>("DesktopLyricsFontName")
    static let desktopLyricsFontSize = Key<Int>("DesktopLyricsFontSize")
    static let desktopLyricsFontNameFallback = Key<[String]>("DesktopLyricsFontNameFallback")
    
    static let desktopLyricsColor = Key<NSColor>("DesktopLyricsColor", transformer: .keyedArchive)
    static let desktopLyricsProgressColor = Key<NSColor>("DesktopLyricsProgressColor", transformer: .keyedArchive)
    static let desktopLyricsShadowColor = Key<NSColor>("DesktopLyricsShadowColor", transformer: .keyedArchive)
    static let desktopLyricsBackgroundColor = Key<NSColor>("DesktopLyricsBackgroundColor", transformer: .keyedArchive)
    
    static let lyricsWindowFontName = Key<String>("LyricsWindowFontName")
    static let lyricsWindowFontSize = Key<Int>("LyricsWindowFontSize")
    static let lyricsWindowFontNameFallback = Key<[String]>("LyricsWindowFontNameFallback")
    
    static let lyricsWindowTextColor = Key<NSColor>("LyricsWindowTextColor", transformer: .keyedArchive)
    static let lyricsWindowHighlightColor = Key<NSColor>("LyricsWindowHighlightColor", transformer: .keyedArchive)
    
    // Shortcut
    static let shortcutToggleMenuBarLyrics = Key<String>("ShortcutToggleMenuBarLyrics")
    static let shortcutToggleKaraokeLyrics = Key<String>("ShortcutToggleKaraokeLyrics")
    static let shortcutShowLyricsWindow = Key<String>("ShortcutShowLyricsWindow")
    static let shortcutOffsetIncrease = Key<String>("ShortcutOffsetIncrease")
    static let shortcutOffsetDecrease = Key<String>("ShortcutOffsetDecrease")
    static let shortcutWriteToiTunes = Key<String>("ShortcutWriteToiTunes")
    static let shortcutSearchLyrics = Key<String>("ShortcutSearchLyrics")
    static let shortcutWrongLyrics = Key<String>("ShortcutWrongLyrics")
    
    // Filter
    static let lyricsFilterEnabled = Key<Bool>("LyricsFilterEnabled")
    static let lyricsSmartFilterEnabled = Key<Bool>("LyricsSmartFilterEnabled")
    static let lyricsFilterKeys = Key<[String]>("LyricsFilterKeys")
    
    // Lab
    static let useSystemWideNowPlaying = Key<Bool>("UseSystemWideNowPlaying")
    
    static let writeiTunesWithTranslation = Key<Bool>("WriteiTunesWithTranslation")
    static let writeToiTunesAutomatically = Key<Bool>("WriteToiTunesAutomatically")
    
    static let globalLyricsOffset = Key<Int>("GlobalLyricsOffset")
    
    //
    static let isInMASReview = Key<Bool?>("isInMASReview")
    
    static let launchHelperTime = Key<Date?>("launchHelperTime")
    
    static let appleLanguages = Key<[String]>("AppleLanguages")
}

extension CGFloat: DefaultConstructible {}
