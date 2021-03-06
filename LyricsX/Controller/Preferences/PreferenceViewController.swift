//
//  PreferenceViewController.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
