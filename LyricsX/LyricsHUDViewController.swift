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
    
    @IBOutlet weak var lyricsTextView: NSTextView!
    @IBOutlet weak var withTagButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    var lyrics: Lyrics? {
        didSet {
            updateTextView()
        }
    }
    
    dynamic var isEditing = false
    var withTag = Preference[DisplayLyricsWithTag]
    
    override func viewDidLoad() {
        lyrics = appDelegate()?.mediaPlayerHelper.currentLyrics
        editButton.isEnabled = lyrics != nil
        Preference.subscribe(key: DisplayLyricsWithTag) { [weak self] (change) in
            self?.withTag = change.newValue
            self?.updateTextView()
        }
        lyricsTextView.bind("isEditable", to: self, withKeyPath: "isEditing")
        super.viewDidLoad()
    }
    
    @IBAction func editLyricsAction(_ sender: NSButton) {
        if isEditing {
            if let lrcContent = lyricsTextView.string,
                var lrc = Lyrics(lrcContent) {
                lrc.metadata = lyrics!.metadata
                lrc.filtrate()
                appDelegate()?.mediaPlayerHelper.currentLyrics = lrc
                lrc.saveToLocal()
            }
            view.window?.close()
        } else {
            withTagButton.state = NSOnState
            withTagButton.isEnabled = false
            lyricsTextView.isEditable = true
            isEditing = true
            sender.title = "Save"
        }
    }
    
    func updateTextView() {
        lyricsTextView.string = lyrics?.contentString(withMetadata: false,
                                                      ID3: withTag,
                                                      timeTag: withTag,
                                                      translation: true)
    }
    
}
