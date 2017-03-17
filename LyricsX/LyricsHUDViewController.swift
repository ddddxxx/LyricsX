//
//  LyricsHUDViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import EasyPreference

class LyricsHUDViewController: NSViewController {
    
    @IBOutlet var lyricsTextView: NSTextView!
    
    var lyrics: LXLyrics? {
        didSet {
            updateTextView()
        }
    }
    
    var withTag = Preference[DisplayLyricsWithTag] {
        didSet {
            updateTextView()
        }
    }
    
    override func viewDidLoad() {
        Preference.subscribe(key: DisplayLyricsWithTag) { [weak self] (change) in
            self?.withTag = change.newValue
        }
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        lyrics = appDelegate.helper.currentLyrics
        super.viewDidLoad()
    }
    
    func updateTextView() {
        if withTag {
            lyricsTextView.string = lyrics?.description
        } else {
            lyricsTextView.string = lyrics?.lyrics.map({$0.sentence}).joined(separator: "\n")
        }
    }
    
}
