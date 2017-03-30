//
//  ScrollLyricsView.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/30.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class ScrollLyricsView: NSScrollView {
    
    private var textView: NSTextView!
    
    var lyrics: Lyrics? {
        didSet { setupTextContents() }
    }
    
    var fadeStripWidth: CGFloat = 24
    
    private var ranges: [(Double, NSRange)] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        drawsBackground = false
        borderType = .noBorder
        hasHorizontalScroller = false
        hasVerticalScroller = false
        textView = NSTextView(frame: frame)
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        textView.alignment = .center
        textView.drawsBackground = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.autoresizingMask = [.viewWidthSizable]
        documentView = textView
    }
    
    func setupTextContents() {
        ranges = []
        
        guard let lyrics = lyrics else {
            textView.string = ""
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
        
        textView.string = lrcContent
        textView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), range: NSMakeRange(0, textView.string!.characters.count))
    }
    
    override func layout() {
        super.layout()
        updateFadeEdgeMask()
        updateEdgeInset()
    }
    
    func updateFadeEdgeMask() {
        let location = fadeStripWidth / frame.height
        
        let mask = CAGradientLayer()
        mask.frame = bounds
        mask.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        mask.locations = [0, location as NSNumber, (1 - location) as NSNumber, 1]
        mask.startPoint = .zero
        mask.endPoint = CGPoint(x: 0, y: 1)
        wantsLayer = true
        layer?.mask = mask
    }
    
    func updateEdgeInset() {
        guard ranges.count > 0 else {
            return
        }
        
        let bounding1 = textView.layoutManager!.boundingRect(forGlyphRange: ranges.first!.1, in: textView.textContainer!)
        let topInset = frame.height/2 - bounding1.height/2
        let bounding2 = textView.layoutManager!.boundingRect(forGlyphRange: ranges.last!.1, in: textView.textContainer!)
        let BottomInset = frame.height/2 - bounding2.height/2
        automaticallyAdjustsContentInsets = false
        contentInsets = EdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
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
        
        textView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), range: NSMakeRange(0, textView.string!.characters.count))
        textView.textStorage?.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), range: range)
        let bounding = textView.layoutManager!.boundingRect(forGlyphRange: range, in: textView.textContainer!)
        let point = NSPoint(x: 0, y: bounding.midY - frame.height / 2)
        textView.scroll(point)
    }
    
}
