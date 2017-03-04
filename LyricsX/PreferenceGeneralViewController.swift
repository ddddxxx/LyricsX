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
    
    override func viewDidLoad() {
        let path = UserDefaults.standard.string(forKey: LyricsCustomSavingPath)!
        savingPathPopUp.item(at: 1)?.title = (path as NSString).lastPathComponent
        savingPathPopUp.item(at: 1)?.toolTip = path
    }
    
    @IBAction func chooseSavingPathAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.beginSheetModal(for: self.view.window!) { result in
            if result == NSFileHandlingPanelOKButton {
                let path = openPanel.url!.path
                UserDefaults.standard.set(path, forKey: LyricsCustomSavingPath)
                self.savingPathPopUp.item(at: 1)?.title = (path as NSString).lastPathComponent
                self.savingPathPopUp.item(at: 1)?.toolTip = path
            }
            UserDefaults.standard.set(NSNumber(value: 1 as Int), forKey: LyricsSavingPathPopUpIndex)
        }
    }
    
}
