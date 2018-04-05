//
//  PreferenceDisplayViewController.swift
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

class PreferenceDisplayViewController: NSViewController, NSWindowDelegate {
    
    var karaokeFont = NSFont(name: defaults[.DesktopLyricsFontName],
                             size: CGFloat(defaults[.DesktopLyricsFontSize]))
        ?? NSFont.labelFont(ofSize: CGFloat(defaults[.DesktopLyricsFontSize]))
    var hudFont = NSFont(name: defaults[.LyricsWindowFontName],
                         size: CGFloat(defaults[.LyricsWindowFontSize]))
        ?? NSFont.labelFont(ofSize: CGFloat(defaults[.LyricsWindowFontSize]))
    
    // TODO: ugly code
    var isSettingKaraokeFont = true
    
    override func viewDidLoad() {
        _ = PreferenceDisplayViewController.swizzler
        super.viewDidLoad()
    }
    
    override func viewDidDisappear() {
        let fontManger = NSFontManager.shared
        if fontManger.target === self {
            fontManger.target = nil
            NSFontPanel.shared.close()
        }
    }
    
    override func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else {
            return
        }
        
        if isSettingKaraokeFont {
            let previousFontFamily = karaokeFont.familyName
            karaokeFont = manager.convert(karaokeFont)
            if previousFontFamily != karaokeFont.familyName {
                // guarantee different font family of font fallback
                var fallback = defaults[.DesktopLyricsFontNameFallback]
                if let index = fallback.index(of: defaults[.DesktopLyricsFontName]) {
                    fallback.remove(at: index)
                }
                fallback.insert(defaults[.DesktopLyricsFontName], at: 0)
                defaults[.DesktopLyricsFontNameFallback] = Array(fallback.prefix(fontNameFallbackCountMax))
            }
            defaults[.DesktopLyricsFontName] = karaokeFont.fontName
            defaults[.DesktopLyricsFontSize] = Int(karaokeFont.pointSize)
        } else {
            hudFont = manager.convert(hudFont)
            defaults[.LyricsWindowFontName] = hudFont.fontName
            defaults[.LyricsWindowFontSize] = Int(hudFont.pointSize)
        }
    }
    
    static let swizzler: () = {
        let cls = PreferenceDisplayViewController.self
        let sel = #selector(NSObject.validModesForFontPanel)
        let dummySel = #selector(PreferenceDisplayViewController.dummyValidModesForFontPanel)
        guard let dummyIMP = class_getMethodImplementation(cls, dummySel),
            let dummyImpl = class_getInstanceMethod(cls, dummySel),
            let typeEncoding = method_getTypeEncoding(dummyImpl) else {
                fatalError("failed to replace method \(sel) in \(cls)")
        }
        class_replaceMethod(cls, sel, dummyIMP, typeEncoding)
    }()
    
    @objc func dummyValidModesForFontPanel(_ fontPanel: NSFontPanel) -> UInt32 {
        return NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelFaceModeMask
    }
    
    @IBAction func showFontPanel(_ sender: NSButton) {
        isSettingKaraokeFont = sender.tag == 0
        let fontManger = NSFontManager.shared
        let fontPanel = fontManger.fontPanel(true)
        fontManger.target = self
        fontManger.setSelectedFont(isSettingKaraokeFont ? karaokeFont : hudFont, isMultiple: false)
        fontPanel?.delegate = self
        fontPanel?.makeKeyAndOrderFront(self)
    }
    
}

class AlphaColorWell: NSColorWell {
    
    override func activate(_ exclusive: Bool) {
        NSColorPanel.shared.showsAlpha = true
        super.activate(exclusive)
    }
    
    override func deactivate() {
        super.deactivate()
        NSColorPanel.shared.showsAlpha = false
    }
    
}
