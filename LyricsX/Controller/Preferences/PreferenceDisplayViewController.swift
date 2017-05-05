//
//  PreferenceDisplayViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/9.
//
//  Copyright (C) 2017  Xander Deng
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
