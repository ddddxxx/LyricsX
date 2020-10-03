//
//  DonateViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
//

import Cocoa

class DonateViewController: NSViewController {
    
    @IBAction func showDebugPanelAction(_ sender: Any) {
        performSegue(withIdentifier: "ShowDebugPanel", sender: sender)
    }
}
