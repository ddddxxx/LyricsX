//
//  LyricsHUDViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class LyricsHUDViewController: NSViewController {
    
    @IBOutlet var lyricsTextView: NSTextView!
    
    override func viewDidLoad() {
        lyricsTextView.font = .systemFont(ofSize: 13)
        lyricsTextView.textColor = NSColor(white: 0.9, alpha: 1)
    }
    
    override func viewWillAppear() {
        lyricsTextView.string = (NSApplication.shared().delegate as? AppDelegate)?.helper.currentLyrics?.description
    }
    
}
