//
//  PreferencesDisplayViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/9.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferencesDisplayViewController: NSViewController {
    
    @IBOutlet weak var fontDisplay: NSTextField!
    
    var fontName: String!
    var fontSize: Int!
    var font: NSFont!
    var height = UserDefaults.standard.integer(forKey: DesktopLyricsHeighFromDock) {
        didSet {
            UserDefaults.standard.set(height, forKey: DesktopLyricsHeighFromDock)
        }
    }
    
    override func viewDidLoad() {
        fontName = UserDefaults.standard.string(forKey: DesktopLyricsFontName)
        fontSize = UserDefaults.standard.integer(forKey: DesktopLyricsFontSize)
        font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        updateFontDisplay()
        
        super.viewDidLoad()
    }
    
    override func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else {
            return
        }
        
        font = manager.convert(font)
        
        fontName = font.fontName
        fontSize = Int(font.pointSize)
        
        updateFontDisplay()
        
        UserDefaults.standard.set(fontName, forKey: DesktopLyricsFontName)
        UserDefaults.standard.set(fontSize, forKey: DesktopLyricsFontSize)
    }
    
    override func validModesForFontPanel(_ fontPanel: NSFontPanel) -> Int {
        return Int(NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelFaceModeMask)
    }
    
    func updateFontDisplay() {
        fontDisplay.stringValue = "\(fontName!) - \(fontSize!)"
    }
    
    @IBAction func showFontPanel(_ sender: NSButton) {
        let fontManger: NSFontManager = NSFontManager.shared()
        let fontPanel: NSFontPanel = NSFontPanel.shared()
        fontManger.target = self
        fontManger.setSelectedFont(font, isMultiple: false)
        fontPanel.makeKeyAndOrderFront(self)
    }
    
    
}
