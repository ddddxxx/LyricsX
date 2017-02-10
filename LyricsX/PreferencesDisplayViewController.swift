//
//  PreferencesDisplayViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/9.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferencesDisplayViewController: NSViewController {
    
//    var fontName = UserDefaults.standard.string(forKey: DesktopLyricsFontName)
    var font = NSFont()
    @IBOutlet weak var fontDisplay: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else {
            return
        }
        
        font = manager.convert(font)
        fontDisplay.stringValue = (font.displayName ?? font.fontName) + " - " + "\(font.pointSize)"
    }
    
    override func validModesForFontPanel(_ fontPanel: NSFontPanel) -> Int {
        return Int(NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelFaceModeMask)
    }
    
    @IBAction func showFontPanel(_ sender: NSButton) {
        let fontManger: NSFontManager = NSFontManager.shared()
        let fontPanel: NSFontPanel = NSFontPanel.shared()
        fontManger.target = self
        fontManger.setSelectedFont(font, isMultiple: false)
        fontPanel.makeKeyAndOrderFront(self)
    }
    
    
}
