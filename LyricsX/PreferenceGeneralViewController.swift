//
//  PreferenceGeneralViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferenceGeneralViewController: NSViewController {
    
    @IBOutlet weak var preferiTunes: NSButton!
    @IBOutlet weak var preferSpotify: NSButton!
    @IBOutlet weak var preferVox: NSButton!
    
    @IBOutlet weak var savingPathPopUp: NSPopUpButton!
    @IBOutlet weak var userPathMenuItem: NSMenuItem!
    
    override func viewDidLoad() {
        switch Preference[PreferredPlayerIndex] {
        case 0:
            preferSpotify.state = 1
        case 1:
            preferiTunes.state = 1
        case 2:
            preferVox.state = 1
        default:
            break
        }
        
        if let url = Preference.lyricsCustomSavingPath {
            savingPathPopUp.item(at: 1)?.title = url.lastPathComponent
            savingPathPopUp.item(at: 1)?.toolTip = url.path
        }
    }
    
    @IBAction func chooseSavingPathAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.beginSheetModal(for: self.view.window!) { result in
            if result == NSFileHandlingPanelOKButton {
                let url = openPanel.url!
                Preference.lyricsCustomSavingPath = url
                self.savingPathPopUp.item(at: 1)?.title = url.lastPathComponent
                self.savingPathPopUp.item(at: 1)?.toolTip = url.path
                self.savingPathPopUp.selectItem(at: 1)
            } else {
                self.savingPathPopUp.selectItem(at: 0)
            }
        }
    }
    
    @IBAction func preferredPlayerAction(_ sender: NSButton) {
        Preference[PreferredPlayerIndex] = sender.tag
    }
    
}
