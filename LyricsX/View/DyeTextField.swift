//
//  DyeTextField.swift
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

class DyeTextField: NSTextField {
    
    let dyeRect = NSView()
    
    let dyeMaskTextField = NSTextField(labelWithString: "")
    
    @objc dynamic var dyeColor: NSColor? {
        get {
            return dyeRect.layer?.backgroundColor.flatMap(NSColor.init(cgColor:))
        }
        set {
            dyeRect.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    var _rectArray: [NSRect]?
    var rectArray: [NSRect] {
        if let _rectArray = _rectArray {
            return _rectArray
        }
        let newRectArray = rectArrayForAllCharacters()
        _rectArray = newRectArray
        return newRectArray
    }
    
    var observations: [NSKeyValueObservation] = []
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(string stringValue: String) {
        self.init(frame: .zero)
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
    
    func commonInit() {
        addSubview(dyeRect)
        
        dyeRect.wantsLayer = true
        dyeMaskTextField.wantsLayer = true
        dyeRect.translatesAutoresizingMaskIntoConstraints = false
        dyeMaskTextField.translatesAutoresizingMaskIntoConstraints = false
        dyeMaskTextField.textColor = .black
        dyeRect.layer?.mask = dyeMaskTextField.layer
        observations += [
            observe(\.stringValue, options: [.new]) { [unowned self] obj, change in
                if let str = change.newValue {
                    self.dyeMaskTextField.stringValue = str
                }
                self._rectArray = nil
            },
            observe(\.font, options: [.new]) { [unowned self] obj, change in
                self.dyeMaskTextField.font = change.newValue ?? nil
                self._rectArray = nil
            }
        ]
    }
    
    deinit {
        observations.forEach { $0.invalidate() }
    }
    
    // MARK: -
    
    override func layout() {
        super.layout()
        updateDyeFrame()
    }

    func updateDyeFrame() {
        dyeRect.frame.size.height = bounds.height
        dyeMaskTextField.frame = bounds
    }
}

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
