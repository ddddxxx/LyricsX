//
//  ScrollLyricsView.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import LyricsCore
import OpenCC

protocol ScrollLyricsViewDelegate: AnyObject {
    func doubleClickLyricsLine(at position: TimeInterval)
    func scrollWheelDidStartScroll()
    func scrollWheelDidEndScroll()
}

class ScrollLyricsView: NSScrollView {
    
    weak var delegate: ScrollLyricsViewDelegate?
    
    private var textView: NSTextView {
        // swiftlint:disable:next force_cast
        return documentView as! NSTextView
    }
    
    var fadeStripWidth: CGFloat = 24
    
    @objc dynamic var textColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1) {
        didSet {
            DispatchQueue.main.async {
                let range = self.textView.string.fullRange
                self.textView.textStorage?.addAttribute(.foregroundColor, value: self.textColor, range: range)
                if let highlightedRange = self.highlightedRange {
                    self.textView.textStorage?.addAttribute(.foregroundColor, value: self.highlightColor, range: highlightedRange)
                }
            }
        }
    }
    
    @objc dynamic var highlightColor = #colorLiteral(red: 0.8866666667, green: 1, blue: 0.8, alpha: 1) {
        didSet {
            guard let highlightedRange = self.highlightedRange else { return }
            DispatchQueue.main.async {
                self.textView.textStorage?.addAttribute(.foregroundColor, value: self.highlightColor, range: highlightedRange)
            }
        }
    }
    
    @objc dynamic var fontName = "Helvetica" {
        didSet { updateFont() }
    }
    
    @objc dynamic var fontSize: CGFloat = 12 {
        didSet { updateFont() }
    }
    
    private var ranges: [(TimeInterval, NSRange)] = []
    private var highlightedRange: NSRange?
    
    func setupTextContents(lyrics: Lyrics?) {
        guard let lyrics = lyrics else {
            ranges = []
            textView.string = ""
            highlightedRange = nil
            return
        }
        
        var lrcContent = ""
        var newRanges: [(TimeInterval, NSRange)] = []
        let enabledLrc = lyrics.lines.filter({ $0.enabled && !$0.content.isEmpty })
        let languageCode = lyrics.metadata.translationLanguages.first
        
        for line in enabledLrc {
            var lineStr = line.content
            if var trans = line.attachments[.translation(languageCode: languageCode)], defaults[.preferBilingualLyrics],
                languageCode?.hasPrefix("zh") == true {
                if let converter = ChineseConverter.shared {
                    trans = converter.convert(trans)
                }
                lineStr += "\n" + trans
            }
            let range = NSRange(location: lrcContent.utf16.count, length: lineStr.utf16.count)
            newRanges.append((line.position, range))
            lrcContent += lineStr
            if line != enabledLrc.last {
                lrcContent += "\n\n"
            }
        }
        ranges = newRanges
        textView.string = lrcContent
        highlightedRange = nil
        let range = textView.string.fullRange
        let font = NSFont(name: fontName, size: fontSize)!
        let style = NSMutableParagraphStyle().with {
            $0.alignment = .center
        }
        textView.textStorage?.addAttributes([
            .foregroundColor: textColor,
            .paragraphStyle: style,
            .font: font
            ], range: range)
        needsLayout = true
    }
    
    override func layout() {
        super.layout()
        updateFadeEdgeMask()
        updateEdgeInset()
    }
    
    override func mouseUp(with event: NSEvent) {
        guard event.clickCount == 2 else {
            super.mouseUp(with: event)
            return
        }
        
        let clickPoint = textView.convert(event.locationInWindow, from: nil)
        let clickRange = ranges.filter { _, range in
            let bounding = textView.layoutManager!.boundingRect(forGlyphRange: range, in: textView.textContainer!)
            return bounding.contains(clickPoint)
        }
        if let (position, _) = clickRange.first {
            delegate?.doubleClickLyricsLine(at: position)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        switch event.momentumPhase {
        case .began:
            delegate?.scrollWheelDidStartScroll()
        case .ended, .cancelled:
            delegate?.scrollWheelDidEndScroll()
        default:
            break
        }
    }
    
    // overriding scrollwheel method breaks trackpad responsive scrolling ability
    override class var isCompatibleWithResponsiveScrolling: Bool {
        return true
    }
    
    private func updateFadeEdgeMask() {
        let location = fadeStripWidth / frame.height
        wantsLayer = true
        layer?.mask = CAGradientLayer().then {
            $0.frame = bounds
            $0.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)] as [CGColor]
            $0.locations = [0, location as NSNumber, (1 - location) as NSNumber, 1]
            $0.startPoint = .zero
            $0.endPoint = CGPoint(x: 0, y: 1)
        }
    }
    
    private func updateEdgeInset() {
        guard !ranges.isEmpty else {
            return
        }
        
        let bounding1 = textView.layoutManager!.boundingRect(forGlyphRange: ranges.first!.1, in: textView.textContainer!)
        let topInset = frame.height / 2 - bounding1.height / 2
        let bounding2 = textView.layoutManager!.boundingRect(forGlyphRange: ranges.last!.1, in: textView.textContainer!)
        let bottomInset = frame.height / 2 - bounding2.height / 2
        automaticallyAdjustsContentInsets = false
        contentInsets = NSEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    }
    
    func highlight(position: TimeInterval) {
        guard !ranges.isEmpty else {
            return
        }
        
        var left = ranges.startIndex
        var right = ranges.endIndex - 1
        while left <= right {
            let mid = (left + right) / 2
            if ranges[mid].0 <= position {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        let range = ranges[right.clamped(to: ranges.indices)].1
        
        if highlightedRange == range {
            return
        }
        
        highlightedRange.map { textView.textStorage?.addAttribute(.foregroundColor, value: textColor, range: $0) }
        textView.textStorage?.addAttribute(.foregroundColor, value: highlightColor, range: range)
        
        highlightedRange = range
    }
    
    func scroll(position: TimeInterval) {
        guard !ranges.isEmpty else {
            return
        }
        
        var left = ranges.startIndex
        var right = ranges.endIndex - 1
        while left <= right {
            let mid = (left + right) / 2
            if ranges[mid].0 <= position {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        let range = ranges[right.clamped(to: ranges.indices)].1
        
        let bounding = textView.layoutManager!.boundingRect(forGlyphRange: range, in: textView.textContainer!)
        
        let point = NSPoint(x: 0, y: bounding.midY - frame.height / 2)
        textView.scroll(point)
    }
    
    func updateFont() {
        let range = textView.string.fullRange
        let font = NSFont(name: fontName, size: fontSize)!
        textView.textStorage?.addAttribute(.font, value: font, range: range)
    }
    
}
