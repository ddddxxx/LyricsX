//
//  PreferenceGeneralViewController.swift
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

class PreferenceGeneralViewController: NSViewController {
    
    @IBOutlet weak var preferAuto: NSButton!
    @IBOutlet weak var preferiTunes: NSButton!
    @IBOutlet weak var preferSpotify: NSButton!
    @IBOutlet weak var preferVox: NSButton!
    
    @IBOutlet weak var autoLaunchButton: NSButton!
    
    @IBOutlet weak var savingPathPopUp: NSPopUpButton!
    @IBOutlet weak var userPathMenuItem: NSMenuItem!
    
    @IBOutlet weak var loadHomonymLrcButton: NSButton!
    
    override func viewDidLoad() {
        switch defaults[.PreferredPlayerIndex] {
        case 0:
            preferiTunes.state = .on
        case 1:
            preferSpotify.state = .on
            loadHomonymLrcButton.isEnabled = false
        case 2:
            preferVox.state = .on
        default:
            preferAuto.state = .on
            autoLaunchButton.isEnabled = false
        }
        
        if let url = defaults.lyricsCustomSavingPath {
            savingPathPopUp.item(at: 1)?.title = url.lastPathComponent
            savingPathPopUp.item(at: 1)?.toolTip = url.path
        } else {
            savingPathPopUp.item(at: 1)?.isHidden = true
        }
    }
    
    @IBAction func chooseSavingPathAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.beginSheetModal(for: self.view.window!) { result in
            if result == .OK {
                let url = openPanel.url!
                defaults.lyricsCustomSavingPath = url
                self.savingPathPopUp.item(at: 1)?.title = url.lastPathComponent
                self.savingPathPopUp.item(at: 1)?.toolTip = url.path
                self.savingPathPopUp.selectItem(at: 1)
            } else {
                self.savingPathPopUp.selectItem(at: 0)
            }
        }
    }
    
    @IBAction func preferredPlayerAction(_ sender: NSButton) {
        defaults[.PreferredPlayerIndex] = sender.tag
        
        let manager = AppController.shared.playerManager
        switch sender.tag {
        case 0: manager.preferredPlayerName = .itunes
        case 1: manager.preferredPlayerName = .spotify
        case 2: manager.preferredPlayerName = .vox
        default: manager.preferredPlayerName = nil
        }
        
        if sender.tag < 0 {
            autoLaunchButton.isEnabled = false
            autoLaunchButton.state = .off
            defaults[.LaunchAndQuitWithPlayer] = false
        } else {
            autoLaunchButton.isEnabled = true
        }
        
        if sender.tag == 1 {
            loadHomonymLrcButton.isEnabled = false
            loadHomonymLrcButton.state = .off
            defaults[.LoadLyricsBesideTrack] = false
        } else {
            loadHomonymLrcButton.isEnabled = true
        }
    }
    
}
