//
//  PreferenceViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa

class PreferenceViewController: NSTabViewController {
    
    override func viewWillAppear() {
        #if IS_FOR_MAS
            if defaults[.isInMASReview] != false {
                removeTabViewItem(tabViewItems.last!)
            }
            checkForMASReview()
        #endif
    }
}
