//
//  PreferenceDisplayViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
        guard let fallback = defaults[.desktopLyricsFontNameFallback].first else {
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
        defaults[.desktopLyricsFontNameFallback].removeAll()
        updateScreenFontFallback()
    }
    
    func fontChanged(from oldFont: NSFont, to newFont: NSFont, sender: FontSelectTextField) {
        if sender === karaokeFontSelectField {
            defaults[.desktopLyricsFontName] = newFont.fontName
            defaults[.desktopLyricsFontSize] = Int(newFont.pointSize)
            if (oldFont.familyName != nil && oldFont.familyName != newFont.familyName)
                || oldFont.fontName != newFont.fontName {
                // guarantee different font family of font fallback
                var fallback = defaults[.desktopLyricsFontNameFallback]
                if let index = fallback.firstIndex(of: newFont.fontName) {
                    fallback.remove(at: index)
                }
                fallback.insert(oldFont.fontName, at: 0)
                defaults[.desktopLyricsFontNameFallback] = Array(fallback.prefix(fontNameFallbackCountMax))
                updateScreenFontFallback()
            }
        } else if sender === hudFontSelectField {
            defaults[.lyricsWindowFontName] = newFont.fontName
            defaults[.lyricsWindowFontSize] = Int(newFont.pointSize)
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
