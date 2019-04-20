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

class PreferenceDisplayViewController: NSViewController, FontSelectTextFieldDelegate {
    
    @IBOutlet weak var karaokeFontSelectField: FontSelectTextField!
    @IBOutlet weak var hudFontSelectField: FontSelectTextField!
    
    @IBOutlet weak var fontFallbackLabel: NSTextField!
    @IBOutlet weak var removeFontFallbackButton: NSButton!
    
    override func viewDidLoad() {
        karaokeFontSelectField.selectedFont = defaults.desktopLyricsFont
        karaokeFontSelectField.fontChangeDelegate = self
        hudFontSelectField.selectedFont = defaults.lyricsWindowFont
        hudFontSelectField.fontChangeDelegate = self
        updateScreenFontFallback()
        super.viewDidLoad()
    }
    
    func updateScreenFontFallback() {
        guard let fallback = defaults[.DesktopLyricsFontNameFallback].first else {
            fontFallbackLabel.isHidden = true
            removeFontFallbackButton.isHidden = true
            return
        }
        fontFallbackLabel.isHidden = false
        removeFontFallbackButton.isHidden = false
        let format = NSLocalizedString("Font Fallback: %@", comment: "")
        fontFallbackLabel.stringValue = String(format: format, arguments: [fallback])
    }
    
    @IBAction func removeFontFallbackAction(_ sender: Any) {
        defaults[.DesktopLyricsFontNameFallback].removeAll()
        updateScreenFontFallback()
    }
    
    func fontChanged(from oldFont: NSFont, to newFont: NSFont, sender: FontSelectTextField) {
        if sender === karaokeFontSelectField {
            defaults[.DesktopLyricsFontName] = newFont.fontName
            defaults[.DesktopLyricsFontSize] = Int(newFont.pointSize)
            if (oldFont.familyName != nil && oldFont.familyName != newFont.familyName)
                || oldFont.fontName != newFont.fontName {
                // guarantee different font family of font fallback
                var fallback = defaults[.DesktopLyricsFontNameFallback]
                if let index = fallback.firstIndex(of: newFont.fontName) {
                    fallback.remove(at: index)
                }
                fallback.insert(oldFont.fontName, at: 0)
                defaults[.DesktopLyricsFontNameFallback] = Array(fallback.prefix(fontNameFallbackCountMax))
                updateScreenFontFallback()
            }
        } else if sender === hudFontSelectField {
            defaults[.LyricsWindowFontName] = newFont.fontName
            defaults[.LyricsWindowFontSize] = Int(newFont.pointSize)
        }
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
