//
//  PreferenceFilterViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/20.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class PreferenceFilterViewController: NSViewController {
    
    @IBAction func resetFilterKey(_ sender: Any) {
        Preference[LyricsDirectFilterKey] = nil
        Preference[LyricsColonFilterKey] = nil
    }
    
}
