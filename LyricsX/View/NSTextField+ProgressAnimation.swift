//
//  NSTextField+ProgressAnimation.swift
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
import SnapKit

extension NSTextField {
    
    func rectArrayForAllCharacters() -> [NSRect] {
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedStringValue)
        var containerSize = frame.size
        // the imitated text container clip its content whereas text field does not.
        // expand container size to avoid clipping.
        containerSize.width = .infinity
        let textContainer = NSTextContainer(containerSize: containerSize)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        return stringValue.indices.map { index in
            let range = NSRange(index...index, in: stringValue)
            return layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
        }
    }
}

extension NSTextField {
    
    func addProgressAnimation(color: NSColor, progress: [(TimeInterval, Int)]) {
        let progressTextField = NSTextField(labelWithString: stringValue)
        progressTextField.wantsLayer = true
        progressTextField.textColor = color
        addSubview(progressTextField)
        progressTextField.bind(.value, to: self, withKeyPath: "stringValue")
        progressTextField.bind(.font, to: self, withKeyPath: "font")
        progressTextField.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        guard let index = progress.index(where: { $0.0 > 0 }) else { return }
        let rectArray = rectArrayForAllCharacters()
        var map = progress.map { ($0.0, rectArray[rectArray.indices.clamp($0.1 - 1)].maxX) }
        if index > 0 {
            let progress = map[index-1].1 + CGFloat(map[index-1].0) * (map[index].1 - map[index-1].1) / CGFloat(map[index].0 - map[index-1].0)
            map.replaceSubrange(..<index, with: [(0, progress)])
        }
        
        let duration = map.last!.0
        let animation = CAKeyframeAnimation()
        animation.keyTimes = map.map { ($0.0 / duration) as NSNumber }
        animation.values = map.map { $0.1 }
        animation.keyPath = "bounds.size.width"
        animation.duration = duration
        progressTextField.layer?.add(animation, forKey: "inlineProgress")
        
        self.progressTextField?.removeFromSuperview()
        self.progressTextField = progressTextField
    }
    
    private static var associatedObjectHandle = 0
    
    private var progressTextField: NSTextField? {
        get {
            return objc_getAssociatedObject(self, &NSTextField.associatedObjectHandle) as? NSTextField
        }
        set {
            objc_setAssociatedObject(self, &NSTextField.associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc dynamic var progressColor: NSColor? {
        get {
            return progressTextField?.textColor
        }
        set {
            progressTextField?.textColor = newValue
        }
    }
}

extension NSTextField {
    
    @available(macOS, obsoleted: 10.12)
    convenience init(labelWithString stringValue: String) {
        self.init()
        self.stringValue = stringValue
        isEditable = false
        isSelectable = false
        textColor = .labelColor
        backgroundColor = .controlColor
        drawsBackground = false
        isBezeled = false
        alignment = .natural
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
        lineBreakMode = .byClipping
        cell?.isScrollable = true
        cell?.wraps = false
    }
}
