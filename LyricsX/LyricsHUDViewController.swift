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
    
    var lyrics: Lyrics? {
        didSet {
            updateTextView()
        }
    }
    
    var withTag = Preference[DisplayLyricsWithTag]
    
    override func viewDidLoad() {
        lyrics = appDelegate()?.mediaPlayerHelper.currentLyrics
        Preference.subscribe(key: DisplayLyricsWithTag) { [weak self] (change) in
            self?.withTag = change.newValue
            self?.updateTextView()
        }
        super.viewDidLoad()
    }
    
    func updateTextView() {
        lyricsTextView.string = lyrics?.contentString(withMetadata: false,
                                                      ID3: withTag,
                                                      timeTag: withTag,
                                                      translation: true)
    }
    
}
