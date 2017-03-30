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
    
    @IBOutlet weak var lyricsScrollView: NSScrollView!
    @IBOutlet weak var lyricsTextView: NSTextView!
    
    private var ranges: [(Double, NSRange)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextContents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePositionChange), name: .lyricsShouldDisplay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLyricsChange), name: .currentLyricsChange, object: nil)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayout() {
        updateFadeEdgeMask()
        updateEdgeInset()
    }
    
    func setupTextContents() {
        guard let lyrics = appDelegate()?.mediaPlayerHelper.currentLyrics else {
            lyricsTextView.string = ""
            ranges = []
            return
        }
        
        var lrcContent = ""
        let enabledLrc = lyrics.lyrics.filter({ $0.enabled })
        for line in enabledLrc {
            var lineStr = line.sentence
            if let trans = line.translation {
                lineStr += "\n" + trans
            }
            let range = NSRange(location: lrcContent.characters.count, length: lineStr.characters.count)
            ranges.append(line.position, range)
            lrcContent += lineStr + "\n\n"
        }
        
        self.lyricsTextView.string = lrcContent
        
        self.lyricsTextView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), range: NSMakeRange(0, self.lyricsTextView.string!.characters.count))
        self.scroll(position: 0)
    }
    
    func handleLyricsChange(_ n: Notification) {
        ranges = []
        DispatchQueue.main.async {
            self.setupTextContents()
        }
    }
    
    func handlePositionChange(_ n: Notification) {
        guard let pos = n.userInfo?["position"] as? Double else {
            return
        }
        DispatchQueue.main.async {
            self.scroll(position: pos)
        }
    }
    
    func scroll(position: Double) {
        guard ranges.count > 0 else {
            return
        }
        
        let range: NSRange
        if var index = ranges.index(where: { $0.0 > position }) {
            if index > 0 {
                index -= 1
            }
            range = ranges[index].1
        } else {
            range = ranges.last!.1
        }
        
        lyricsTextView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), range: NSMakeRange(0, lyricsTextView.string!.characters.count))
        lyricsTextView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), range: range)
        let bounding = lyricsTextView.layoutManager!.boundingRect(forGlyphRange: range, in: lyricsTextView.textContainer!)
        let point = NSPoint(x: 0, y: bounding.midY - lyricsScrollView.frame.height / 2)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
            lyricsTextView.scroll(point)
        })
    }
    
    func updateFadeEdgeMask() {
        let fadeStripWidth: CGFloat = 24
        let location = fadeStripWidth / lyricsScrollView.frame.height
        
        let mask = CAGradientLayer()
        mask.frame = lyricsScrollView.bounds
        mask.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        mask.locations = [0, location as NSNumber, (1 - location) as NSNumber, 1]
        mask.startPoint = .zero
        mask.endPoint = CGPoint(x: 0, y: 1)
        lyricsScrollView.wantsLayer = true
        lyricsScrollView.layer?.mask = mask
    }
    
    func updateEdgeInset() {
        guard ranges.count > 0 else {
            return
        }
        
        let bounding1 = lyricsTextView.layoutManager!.boundingRect(forGlyphRange: ranges.first!.1, in: lyricsTextView.textContainer!)
        let topInset = lyricsScrollView.frame.height/2 - bounding1.height/2
        let bounding2 = lyricsTextView.layoutManager!.boundingRect(forGlyphRange: ranges.last!.1, in: lyricsTextView.textContainer!)
        let BottomInset = lyricsScrollView.frame.height/2 - bounding2.height/2
        lyricsScrollView.automaticallyAdjustsContentInsets = false
        lyricsScrollView.contentInsets = EdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
        lyricsScrollView.scrollerInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
