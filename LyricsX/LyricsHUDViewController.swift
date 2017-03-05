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
    @IBOutlet weak var useLrcButton: NSButton!
    
    var lyrics: LXLyrics? {
        didSet {
            lyricsTextView.string = lyrics?.description
            useLrcButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        lyricsTextView.font = .systemFont(ofSize: 13)
        lyricsTextView.textColor = NSColor(white: 0.9, alpha: 1)
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        lyrics = appDelegate.helper.currentLyrics
        super.viewDidLoad()
    }
    
    @IBAction func useLrc(_ sender: Any) {
        (NSApplication.shared().delegate as? AppDelegate)?.helper.currentLyrics = lyrics
        useLrcButton.isEnabled = false
    }
    
}
