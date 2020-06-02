//
//  DebugViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import AppCenterCrashes

class DebugViewController: NSViewController {
    
    @IBAction func crashActioin(_ sender: Any) {
        MSCrashes.generateTestCrash()
    }
}
