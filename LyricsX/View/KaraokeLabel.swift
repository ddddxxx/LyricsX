//
//  KaraokeLabel.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa

class KaraokeLabel: NSTextField {
    
    @objc dynamic var isVertical = false {
        didSet {
            clearCache()
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc dynamic var drawFurigana = false {
        didSet {
            clearCache()
            invalidateIntrinsicContentSize()
        }
    }
    
    override var attributedStringValue: NSAttributedString {
        didSet {
            clearCache()
        }
    }
    
    override var stringValue: String {
        didSet {
            clearCache()
        }
    }
    
    @objc override dynamic var font: NSFont? {
        didSet {
            clearCache()
        }
    }
    
    @objc override dynamic var textColor: NSColor? {
        didSet {
            clearCache()
        }
    }
    
    private func clearCache() {
        _attrString = nil
        _ctFrame = nil
        needsLayout = true
        needsDisplay = true
        removeProgressAnimation()
    }
    
    private var _attrString: NSAttributedString?
    private var attrString: NSAttributedString {
        if let attrString = _attrString {
            return attrString
        }
        let attrString = NSMutableAttributedString(attributedString: attributedStringValue)
        let string = attrString.string as NSString
        let shouldDrawFurigana = drawFurigana && string.dominantLanguage == "ja"
        let tokenizer = CFStringTokenizer.create(string)
        for tokenType in tokenizer where tokenType.contains(.isCJWordMask) {
            if isVertical {
                let tokenRange = tokenizer.currentTokenRange()
                let attr: [NSAttributedStringKey: Any] = [
                    .verticalGlyphForm: true,
                    .baselineOffset: (font?.pointSize ?? 24) * 0.25,
                ]
                attrString.addAttributes(attr, range: tokenRange)
            }
            guard shouldDrawFurigana else { continue }
            if let (furigana, range) = tokenizer.currentFuriganaAnnotation(in: string) {
                var attr: [NSAttributedStringKey: Any] = [.rubyAnnotationSizeFactor: 0.5]
                attr[.foregroundColor] = textColor // Set ruby text color but it seems doesn't work.
                let annotation = CTRubyAnnotation.create(furigana, attributes: attr)
                attrString.addAttribute(.rubyAnnotation, value: annotation, range: range)
            }
        }
        textColor?.do { attrString.addAttributes([.foregroundColor: $0], range: attrString.fullRange) }
        _attrString = attrString
        return attrString
    }
    
    private var _ctFrame: CTFrame?
    private var ctFrame: CTFrame {
        if let ctFrame = _ctFrame {
            return ctFrame
        }
        layoutSubtreeIfNeeded()
        let progression: CTFrameProgression = isVertical ? .rightToLeft : .topToBottom
        let frameAttr: NSDictionary = [kCTFrameProgressionAttributeName: NSNumber(value: progression.rawValue)]
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let fullRange = attrString.fullRange.asCF
        var fitRange = CFRange()
        let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, fullRange, frameAttr, bounds.size, &fitRange)
        let path = CGPath(rect: CGRect(origin: .zero, size: suggestSize), transform: nil)
        let ctFrame = CTFramesetterCreateFrame(framesetter, fitRange, path, frameAttr)
        _ctFrame = ctFrame
        return ctFrame
    }
    
    override func sizeThatFits(_ size: NSSize) -> NSSize {
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let cfRange = attrString.fullRange.asCF
        let progression: CTFrameProgression = isVertical ? .rightToLeft : .topToBottom
        let frameAttr: NSDictionary = [kCTFrameProgressionAttributeName: NSNumber(value: progression.rawValue)]
        let constraints = CGSize(width: CGFloat.infinity, height: .infinity)
        let suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, cfRange, frameAttr, constraints, nil)
        return suggestSize
    }
    
    override func sizeToFit() {
        frame.size = sizeThatFits(.zero)
    }
    
    override var fittingSize: NSSize {
        return sizeThatFits(.zero)
    }
    
    override var intrinsicContentSize: NSSize {
        return sizeThatFits(.zero)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current!.cgContext
        context.textMatrix = .identity
        context.translateBy(x: 0, y: dirtyRect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        CTFrameDraw(ctFrame, context)
    }
    
    // MARK: - Progress
    
    // TODO: multi-line
    private lazy var progressLayer: CALayer = {
        let pLayer = CALayer()
        wantsLayer = true
        layer?.addSublayer(pLayer)
        return pLayer
    }()
    
    @objc dynamic var progressColor: NSColor? {
        get {
            return progressLayer.backgroundColor.flatMap(NSColor.init)
        }
        set {
            progressLayer.backgroundColor = newValue?.cgColor
        }
    }
    
    func setProgressAnimation(color: NSColor, progress: [(TimeInterval, Int)]) {
        removeProgressAnimation()
        guard let line = ctFrame.lines.first,
            let origin = ctFrame.lineOrigins.first else {
                return
        }
        var lineBounds = line.bounds()
        var transform = CGAffineTransform.translate(x: origin.x, y: origin.y)
        if isVertical {
            transform.transform(by: .swap() * .translate(y: -lineBounds.width))
            transform *= .flip(height: bounds.height)
        }
        lineBounds.apply(t: transform)
        
        progressLayer.anchorPoint = isVertical ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0, y: 0.5)
        progressLayer.frame = lineBounds
        progressLayer.backgroundColor = color.cgColor
        let mask = CALayer()
        mask.frame = progressLayer.bounds
        let img = NSImage(size: progressLayer.bounds.size, flipped: false) { _ in
            let context = NSGraphicsContext.current!.cgContext
            let ori = lineBounds.applying(.flip(height: self.bounds.height)).origin
            context.concatenate(.translate(x: -ori.x, y: -ori.y))
            CTFrameDraw(self.ctFrame, context)
            return true
        }
        mask.contents = img.cgImage(forProposedRect: nil, context: nil, hints: nil)
        progressLayer.mask = mask

        guard let index = progress.index(where: { $0.0 > 0 }) else { return }
        var map = progress.map { ($0.0, line.offset(charIndex: $0.1)) }
        if index > 0 {
            let progress = map[index - 1].1 + CGFloat(map[index - 1].0) * (map[index].1 - map[index - 1].1) / CGFloat(map[index].0 - map[index - 1].0)
            map.replaceSubrange(..<index, with: [(0, progress)])
        }

        let duration = map.last!.0
        let animation = CAKeyframeAnimation()
        animation.keyTimes = map.map { ($0.0 / duration) as NSNumber }
        animation.values = map.map { $0.1 }
        animation.keyPath = isVertical ? "bounds.size.height" : "bounds.size.width"
        animation.duration = duration
        progressLayer.add(animation, forKey: "inlineProgress")
    }
    
    func pauseProgressAnimation() {
        let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0
        progressLayer.timeOffset = pausedTime
    }
    
    func resumeProgressAnimation() {
        let pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1
        progressLayer.timeOffset = 0
        progressLayer.beginTime = 0
        let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressLayer.beginTime = timeSincePause
    }
    
    func removeProgressAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.speed = 1
        progressLayer.timeOffset = 0
        progressLayer.removeAnimation(forKey: "inlineProgress")
        progressLayer.frame = .zero
        CATransaction.commit()
    }
}
