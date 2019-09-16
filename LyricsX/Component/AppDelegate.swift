//
//  AppDelegate.swift
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
import Crashlytics
import Fabric
import GenericID
import MASShortcut
import MusicPlayer

#if IS_FOR_MAS
#else
import Sparkle
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuItemValidation, NSMenuDelegate {
    
    static var shared: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }
    
    @IBOutlet weak var lyricsOffsetTextField: NSTextField!
    @IBOutlet weak var lyricsOffsetStepper: NSStepper!
    @IBOutlet weak var statusBarMenu: NSMenu!
    
    var desktopLyrics: KaraokeLyricsWindowController?
    
    var _touchBarLyrics: Any?
    
    @available(OSX 10.12.2, *)
    var touchBarLyrics: TouchBarLyrics? {
        return self._touchBarLyrics as! TouchBarLyrics?
    }
    
    lazy var searchLyricsWC: NSWindowController = {
        // swiftlint:disable:next force_cast
        let searchVC = NSStoryboard.main!.instantiateController(withIdentifier: .init("SearchLyricsViewController")) as! SearchLyricsViewController
        let window = NSWindow(contentViewController: searchVC)
        window.title = NSLocalizedString("Search Lyrics", comment: "window title")
        return NSWindowController(window: window)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerUserDefaults()
        #if RELEASE
            Fabric.with([Crashlytics.self])
        #endif
        
        let controller = AppController.shared
        
        desktopLyrics = KaraokeLyricsWindowController()
        desktopLyrics?.showWindow(nil)
        
        MenuBarLyrics.shared.statusItem.menu = statusBarMenu
        statusBarMenu.delegate = self
        
        lyricsOffsetStepper.bind(.value,
                                 to: controller,
                                 withKeyPath: #keyPath(AppController.lyricsOffset),
                                 options: [.continuouslyUpdatesValue: true])
        lyricsOffsetTextField.bind(.value,
                                   to: controller,
                                   withKeyPath: #keyPath(AppController.lyricsOffset),
                                   options: [.continuouslyUpdatesValue: true])
        
        setupShortcuts()
        
        NSRunningApplication.runningApplications(withBundleIdentifier: lyricsXHelperIdentifier).forEach { $0.terminate() }
        
        let sharedKeys: [UserDefaults.DefaultsKeys] = [
            .LaunchAndQuitWithPlayer,
            .PreferredPlayerIndex,
        ]
        sharedKeys.forEach {
            groupDefaults.bind(NSBindingName($0.key), withDefaultName: $0)
        }
        
        #if IS_FOR_MAS
        checkForMASReview(force: true)
        #else
        SUUpdater.shared()?.checkForUpdatesInBackground()
        if #available(OSX 10.12.2, *) {
            observeDefaults(key: .TouchBarLyricsEnabled, options: [.new, .initial]) { [unowned self] _, change in
                if change.newValue, self.touchBarLyrics == nil {
                    self._touchBarLyrics = TouchBarLyrics()
                } else if !change.newValue, self.touchBarLyrics != nil {
                    self._touchBarLyrics = nil
                }
            }
        }
        #endif
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if AppController.shared.currentLyrics?.metadata.needsPersist == true {
            AppController.shared.currentLyrics?.persist()
        }
        if defaults[.LaunchAndQuitWithPlayer] {
            let url = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LoginItems/LyricsXHelper.app")
            groupDefaults[.launchHelperTime] = Date()
            do {
                try NSWorkspace.shared.launchApplication(at: url, configuration: [:])
                log("launch LyricsX Helper succeed.")
            } catch {
                log("launch LyricsX Helper failed. reason: \(error)")
            }
        }
    }
    
    private func setupShortcuts() {
        let binder = MASShortcutBinder.shared()!
        binder.bindBoolShortcut(.ShortcutToggleMenuBarLyrics, target: .MenuBarLyricsEnabled)
        binder.bindBoolShortcut(.ShortcutToggleKaraokeLyrics, target: .DesktopLyricsEnabled)
        binder.bindShortcut(.ShortcutShowLyricsWindow, to: #selector(showLyricsHUD))
        binder.bindShortcut(.ShortcutOffsetIncrease, to: #selector(increaseOffset))
        binder.bindShortcut(.ShortcutOffsetDecrease, to: #selector(decreaseOffset))
        binder.bindShortcut(.ShortcutWriteToiTunes, to: #selector(writeToiTunes))
        binder.bindShortcut(.ShortcutWrongLyrics, to: #selector(wrongLyrics))
        binder.bindShortcut(.ShortcutSearchLyrics, to: #selector(searchLyrics))
    }
    
    // MARK: - NSMenuDelegate
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(writeToiTunes(_:))?:
            return AppController.shared.playerManager.player is iTunes && AppController.shared.currentLyrics != nil
        case #selector(searchLyrics(_:))?:
            let track = AppController.shared.playerManager.player?.currentTrack
            let enabled = track != nil
            return enabled
        default:
            return true
        }
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.item(withTag: 202)?.isEnabled = AppController.shared.currentLyrics != nil
    }
    
    // MARK: - Menubar Action
    
    var lyricsHUD: NSWindowController?
    
    @IBAction func showLyricsHUD(_ sender: Any?) {
        // swiftlint:disable:next force_cast
        let controller = lyricsHUD ?? NSStoryboard.main?.instantiateController(withIdentifier: .init("LyricsHUD")) as! NSWindowController
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        lyricsHUD = controller
    }
    
    @IBAction func checkUpdateAction(_ sender: Any) {
        #if IS_FOR_MAS
        assert(false, "should not be there")
        #else
        SUUpdater.shared()?.checkForUpdates(sender)
        #endif
    }
    
    @IBAction func increaseOffset(_ sender: Any?) {
        AppController.shared.lyricsOffset += 100
    }
    
    @IBAction func decreaseOffset(_ sender: Any?) {
        AppController.shared.lyricsOffset -= 100
    }
    
    @IBAction func showCurrentLyricsInFinder(_ sender: Any?) {
        guard let lyrics = AppController.shared.currentLyrics else {
            return
        }
        if lyrics.metadata.needsPersist {
            lyrics.persist()
        }
        if let url = lyrics.metadata.localURL {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    @IBAction func writeToiTunes(_ sender: Any?) {
        AppController.shared.writeToiTunes(overwrite: true)
    }
    
    @IBAction func searchLyrics(_ sender: Any?) {
        searchLyricsWC.window?.makeKeyAndOrderFront(nil)
        (searchLyricsWC.contentViewController as! SearchLyricsViewController?)?.reloadKeyword()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func wrongLyrics(_ sender: Any?) {
        guard let track = AppController.shared.playerManager.player?.currentTrack else {
            return
        }
        defaults[.NoSearchingTrackIds].append(track.id)
        if defaults[.WriteToiTunesAutomatically] {
            track.setLyrics("")
        }
        if let url = AppController.shared.currentLyrics?.metadata.localURL {
            try? FileManager.default.removeItem(at: url)
        }
        AppController.shared.currentLyrics = nil
        AppController.shared.searchProgress?.cancel()
    }
    
    @IBAction func doNotSearchLyricsForThisAlbum(_ sender: Any?) {
        guard let track = AppController.shared.playerManager.player?.currentTrack,
            let album = track.album else {
            return
        }
        defaults[.NoSearchingAlbumNames].append(album)
        if defaults[.WriteToiTunesAutomatically] {
            track.setLyrics("")
        }
        if let url = AppController.shared.currentLyrics?.metadata.localURL {
            try? FileManager.default.removeItem(at: url)
        }
        AppController.shared.currentLyrics = nil
    }
    
    func registerUserDefaults() {
        let currentLang = NSLocale.preferredLanguages.first!
        let isZh = currentLang.hasPrefix("zh") || currentLang.hasPrefix("yue")
        let isHant = isZh && (currentLang.contains("-Hant") || currentLang.contains("-HK"))
        
        let defaultsUrl = Bundle.main.url(forResource: "UserDefaults", withExtension: "plist")!
        if let dict = NSDictionary(contentsOf: defaultsUrl) as? [String: Any] {
            defaults.register(defaults: dict)
        }
        defaults.register(defaults: [
            .DesktopLyricsColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            .DesktopLyricsProgressColor: #colorLiteral(red: 0.1985405816, green: 1, blue: 0.8664234302, alpha: 1),
            .DesktopLyricsShadowColor: #colorLiteral(red: 0, green: 1, blue: 0.8333333333, alpha: 1),
            .DesktopLyricsBackgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279),
            .LyricsWindowTextColor: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1),
            .LyricsWindowHighlightColor: #colorLiteral(red: 0.8866666667, green: 1, blue: 0.8, alpha: 1),
            .PreferBilingualLyrics: isZh,
            .ChineseConversionIndex: isHant ? 2 : 0,
            .DesktopLyricsXPositionFactor: 0.5,
            .DesktopLyricsYPositionFactor: 0.9,
            ])
    }
}

extension MASShortcutBinder {
    
    func bindShortcut<T>(_ defaultsKay: UserDefaults.DefaultsKey<T>, to action: @escaping () -> Void) {
        bindShortcut(withDefaultsKey: defaultsKay.key, toAction: action)
    }
    
    func bindBoolShortcut<T>(_ defaultsKay: UserDefaults.DefaultsKey<T>, target: UserDefaults.DefaultsKey<Bool>) {
        bindShortcut(withDefaultsKey: defaultsKay.key) {
            defaults[target] = !defaults[target]
        }
    }
    
    func bindShortcut<T>(_ defaultsKay: UserDefaults.DefaultsKey<T>, to action: Selector) {
        bindShortcut(defaultsKay) {
            let target = NSApplication.shared.target(forAction: action) as AnyObject?
            _ = target?.perform(action, with: self)
        }
    }
}
