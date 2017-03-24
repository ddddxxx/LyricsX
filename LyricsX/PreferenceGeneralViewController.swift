//
//  PreferenceGeneralViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferenceGeneralViewController: NSViewController {
    
    @IBOutlet weak var savingPathPopUp: NSPopUpButton!
    @IBOutlet weak var userPathMenuItem: NSMenuItem!
    
    override func viewDidLoad() {
        guard let url = Preference.lyricsCustomSavingPath else {
            userPathMenuItem.isHidden = true
            return
        }
        savingPathPopUp.item(at: 1)?.title = url.lastPathComponent
        savingPathPopUp.item(at: 1)?.toolTip = url.path
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
                self.userPathMenuItem.isHidden = false
                self.savingPathPopUp.selectItem(at: 1)
            } else {
                self.savingPathPopUp.selectItem(at: 0)
            }
        }
    }
    
}
