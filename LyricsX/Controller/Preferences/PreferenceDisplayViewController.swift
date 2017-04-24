//
//  PreferenceDisplayViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/9.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferenceDisplayViewController: NSViewController {
    
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    @IBOutlet weak var lyricsColorWell: NSColorWell!
    @IBOutlet weak var shadowColorWell: NSColorWell!
    
    var font: NSFont!
    
    override func viewDidLoad() {
        let fontName = Preference[.DesktopLyricsFontName]!
        let fontSize = Preference[.DesktopLyricsFontSize]
        font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        super.viewDidLoad()
    }
    
    override func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else {
            return
        }
        
        font = manager.convert(font)
        
        Preference[.DesktopLyricsFontName] = font.fontName
        Preference[.DesktopLyricsFontSize] = Int(font.pointSize)
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

class AlphaColorWell: NSColorWell {
    
    override func activate(_ exclusive: Bool) {
        NSColorPanel.shared().showsAlpha = true
        super.activate(exclusive)
    }
    
    override func deactivate() {
        super.deactivate()
        NSColorPanel.shared().showsAlpha = false
    }
    
}
