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
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static var shared: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }
    
    @IBOutlet weak var lyricsOffsetTextField: NSTextField!
    @IBOutlet weak var lyricsOffsetStepper: NSStepper!
    @IBOutlet weak var statusBarMenu: NSMenu!
    
    var desktopLyrics: KaraokeLyricsWindowController?
    
    var touchBarLyrics: Any?
    var touchBarLyricsObservation: DefaultsObservation?
    
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
        
        MenuBarLyrics.shared.statusItem.target = self
        MenuBarLyrics.shared.statusItem.action = #selector(clickMenuBarItem)
        
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
        if !SMLoginItemSetEnabled(lyricsXHelperIdentifier as CFString, defaults[.LaunchAndQuitWithPlayer]) {
            log("Failed to set login item enabled")
        }
        
        let sharedKeys = [
            UserDefaults.DefaultsKeys.LaunchAndQuitWithPlayer.key,
            UserDefaults.DefaultsKeys.PreferredPlayerIndex.key
        ]
        sharedKeys.forEach {
            groupDefaults.bind(NSBindingName($0), to: defaults, withKeyPath: $0)
        }
        
        #if IS_FOR_MAS
            checkForMASReview(force: true)
        #else
            if #available(OSX 10.12.2, *) {
                touchBarLyricsObservation = defaults.observe(.TouchBarLyricsEnabled, options: [.new, .initial]) { [unowned self] _, change in
                    if change.newValue, self.touchBarLyrics == nil {
                        self.touchBarLyrics = TouchBarLyrics()
                    } else if !change.newValue, self.touchBarLyrics != nil {
                        self.touchBarLyrics = nil
                    }
                }
            }
            checkForUpdate()
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
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.identifier {
        case .WriteToiTunes?:
            return AppController.shared.playerManager.player is iTunes && AppController.shared.currentLyrics != nil
        case .WrongLyrics?:
            return AppController.shared.currentLyrics != nil
        default:
            return true
        }
    }
    
    private func setupShortcuts() {
        let binder = MASShortcutBinder.shared()!
        binder.bindBoolShortcut(.ShortcutToggleMenuBarLyrics, target: .MenuBarLyricsEnabled)
        binder.bindBoolShortcut(.ShortcutToggleKaraokeLyrics, target: .DesktopLyricsEnabled)
        binder.bindShortcut(.ShortcutShowLyricsWindow) {
            self.showLyricsHUD(nil)
        }
        binder.bindShortcut(.ShortcutOffsetIncrease) {
            self.increaseOffset(nil)
        }
        binder.bindShortcut(.ShortcutOffsetDecrease) {
            self.decreaseOffset(nil)
        }
        binder.bindShortcut(.ShortcutWriteToiTunes) {
            self.writeToiTunes(nil)
        }
        binder.bindShortcut(.ShortcutWrongLyrics) {
            self.wrongLyrics(nil)
        }
        binder.bindShortcut(.ShortcutSearchLyrics) {
            self.searchLyrics(nil)
        }
    }
    
    // MARK: - Menubar Action
    
    @IBAction func clickMenuBarItem(_ sender: NSStatusItem) {
        #if IS_FOR_MAS
            let isInMASReview = defaults[.isInMASReview] != false
            statusBarMenu.item(withTag: 201)?.isHidden = isInMASReview
            // search lyrics
            statusBarMenu.item(withTag: 401)?.isHidden = isInMASReview || isFromMacAppStore
            // check for update
            statusBarMenu.item(withTag: 402)?.isHidden = isInMASReview
            // donate
            checkForMASReview()
        #endif
        
        statusBarMenu.item(withTag: 202)?.isHidden = !(AppController.shared.playerManager.player is iTunes)
        // write to iTunes
        
        MenuBarLyrics.shared.statusItem.popUpMenu(statusBarMenu)
    }
    
    var lyricsHUD: NSWindowController?
    
    @IBAction func showLyricsHUD(_ sender: Any?) {
        let controller = lyricsHUD ?? NSStoryboard.main?.instantiateController(withIdentifier: .init("LyricsHUD")) as! NSWindowController
        controller.showWindow(nil)
        lyricsHUD = controller
    }
    
    @IBAction func checkUpdateAction(_ sender: Any) {
        checkForUpdate(force: true)
    }
    
    @IBAction func increaseOffset(_ sender: Any?) {
        AppController.shared.lyricsOffset += 100
    }
    
    @IBAction func decreaseOffset(_ sender: Any?) {
        AppController.shared.lyricsOffset -= 100
    }
    
    @IBAction func writeToiTunes(_ sender: Any?) {
        AppController.shared.writeToiTunes(overwrite: true)
    }
    
    @IBAction func searchLyrics(_ sender: Any?) {
        searchLyricsWC.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func wrongLyrics(_ sender: Any?) {
        if let id = AppController.shared.playerManager.player?.currentTrack?.id {
            defaults[.NoSearchingTrackIds].append(id)
        }
        if defaults[.WriteToiTunesAutomatically] {
            (AppController.shared.playerManager.player as? iTunes)?.currentLyrics = ""
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
            .DesktopLyricsShadowColor: #colorLiteral(red: 0, green: 1, blue: 0.8333333333, alpha: 1),
            .DesktopLyricsBackgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6041579279),
            .LyricsWindowTextColor: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1),
            .LyricsWindowHighlightColor: #colorLiteral(red: 0.8866666667, green: 1, blue: 0.8, alpha: 1),
            .PreferBilingualLyrics: isZh,
            .ChineseConversionIndex: isHant ? 2 : 0
            ])
    }
}

extension NSUserInterfaceItemIdentifier {
    
    fileprivate static let WriteToiTunes = NSUserInterfaceItemIdentifier("WriteToiTunes")
    fileprivate static let WrongLyrics = NSUserInterfaceItemIdentifier("WrongLyrics")
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
}
