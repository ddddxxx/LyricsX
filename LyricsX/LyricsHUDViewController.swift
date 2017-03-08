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
    
    var lyrics: LXLyrics? {
        didSet {
            updateTextView(nil)
        }
    }
    
    override func viewDidLoad() {
        UserDefaults.standard.addObserver(self, forKeyPath: DisplayLyricsWithTag, options: .new, context: nil)
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        lyrics = appDelegate.helper.currentLyrics
        super.viewDidLoad()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case .some(DisplayLyricsWithTag):
            updateTextView(nil)
        default:
            break
        }
    }
    
    @IBAction func updateTextView(_ sender: Any?) {
        let withTag = UserDefaults.standard.bool(forKey: DisplayLyricsWithTag)
        if withTag {
            lyricsTextView.string = lyrics?.description
        } else {
            lyricsTextView.string = lyrics?.lyrics.map({$0.sentence}).joined(separator: "\n")
        }
    }
    
}
