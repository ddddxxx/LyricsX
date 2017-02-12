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
    
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    @IBOutlet weak var lyricsColorWell: NSColorWell!
    @IBOutlet weak var shadowColorWell: NSColorWell!
    
    var fontName = UserDefaults.standard.string(forKey: DesktopLyricsFontName)!
    var fontSize = UserDefaults.standard.integer(forKey: DesktopLyricsFontSize)
    var font: NSFont!
    var height = UserDefaults.standard.integer(forKey: DesktopLyricsHeighFromDock) {
        didSet {
            UserDefaults.standard.set(height, forKey: DesktopLyricsHeighFromDock)
        }
    }
    
    override func viewDidLoad() {
        font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        let userDefaults = UserDefaults.standard
        backgroundColorWell.color = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: DesktopLyricsBackgroundColor)!)! as! NSColor
        lyricsColorWell.color = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: DesktopLyricsColor)!)! as! NSColor
        shadowColorWell.color = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: DesktopLyricsShadowColor)!)! as! NSColor
        
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
        fontDisplay.stringValue = "\(fontName) - \(fontSize)"
    }
    
    @IBAction func showFontPanel(_ sender: NSButton) {
        let fontManger: NSFontManager = NSFontManager.shared()
        let fontPanel: NSFontPanel = NSFontPanel.shared()
        fontManger.target = self
        fontManger.setSelectedFont(font, isMultiple: false)
        fontPanel.makeKeyAndOrderFront(self)
    }
    
    @IBAction func changeColorAction(_ sender: NSColorWell) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: lyricsColorWell.color) as AnyObject, forKey: DesktopLyricsColor)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: shadowColorWell.color) as AnyObject, forKey: DesktopLyricsShadowColor)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: backgroundColorWell.color) as AnyObject, forKey: DesktopLyricsBackgroundColor)
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
