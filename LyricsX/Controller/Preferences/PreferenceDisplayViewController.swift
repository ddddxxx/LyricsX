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

class PreferenceDisplayViewController: NSViewController {
    
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    @IBOutlet weak var lyricsColorWell: NSColorWell!
    @IBOutlet weak var shadowColorWell: NSColorWell!
    
    var font: NSFont!
    
    override func viewDidLoad() {
        let fontName = defaults[.DesktopLyricsFontName]!
        let fontSize = defaults[.DesktopLyricsFontSize]
        font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        let _ = PreferenceDisplayViewController.swizzler
        
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
        
        font = manager.convert(font)
        
        defaults[.DesktopLyricsFontName] = font.fontName
        defaults[.DesktopLyricsFontSize] = Int(font.pointSize)
    }
    
    static var swizzler: Any? = {
        let cls = PreferenceDisplayViewController.self
        let sel = #selector(NSObject.validModesForFontPanel)
        let dummySel = #selector(PreferenceDisplayViewController.dummyValidModesForFontPanel)
        guard let dummyIMP = class_getMethodImplementation(cls, dummySel),
            let dummyImpl = class_getInstanceMethod(cls, dummySel),
            let typeEncoding = method_getTypeEncoding(dummyImpl) else {
                fatalError("failed to replace method \(sel) in \(cls)")
        }
        class_replaceMethod(cls, sel, dummyIMP, typeEncoding)
        return nil
    }()
    
    @objc func dummyValidModesForFontPanel(_ fontPanel: NSFontPanel) -> UInt32 {
        return NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelFaceModeMask
    }
    
    @IBAction func showFontPanel(_ sender: NSButton) {
        let fontManger = NSFontManager.shared
        let fontPanel = NSFontPanel.shared
        fontManger.target = self
        fontManger.setSelectedFont(font, isMultiple: false)
        fontPanel.makeKeyAndOrderFront(self)
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
