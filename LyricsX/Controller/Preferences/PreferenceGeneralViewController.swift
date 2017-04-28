//
//  PreferenceGeneralViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferenceGeneralViewController: NSViewController {
    
    @IBOutlet weak var preferAuto: NSButton!
    @IBOutlet weak var preferiTunes: NSButton!
    @IBOutlet weak var preferSpotify: NSButton!
    @IBOutlet weak var preferVox: NSButton!
    
    @IBOutlet weak var autoLaunchButton: NSButton!
    
    @IBOutlet weak var savingPathPopUp: NSPopUpButton!
    @IBOutlet weak var userPathMenuItem: NSMenuItem!
    
    override func viewDidLoad() {
        switch Preference[.PreferredPlayerIndex] {
        case 0:
            preferiTunes.state = NSOnState
        case 1:
            preferSpotify.state = NSOnState
        case 2:
            preferVox.state = NSOnState
        default:
            preferAuto.state = NSOnState
            autoLaunchButton.isEnabled = false
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
        Preference[.PreferredPlayerIndex] = sender.tag
        GroupPreference[.PreferredPlayerIndex] = sender.tag
        if sender.tag < 0 {
            autoLaunchButton.isEnabled = false
            autoLaunchButton.state = NSOffState
            Preference[.LaunchAndQuitWithPlayer] = false
        } else {
            autoLaunchButton.isEnabled = true
        }
    }
    
}
