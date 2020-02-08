//
//  Polyfill.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa

// Not actual polyfills. Despite the `obsoleted` mark, these implementation in
// fact shadows the system provided methods.

// MARK: - 10.12

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

extension NSAnimationContext {
    
    @available(macOS, obsoleted: 10.12)
    class func runAnimationGroup(_ changes: (NSAnimationContext) -> Void) {
        runAnimationGroup(changes, completionHandler: nil)
    }
}

// MARK: - 10.13

extension NSStoryboard {
    
    @available(macOS, obsoleted: 10.13)
    class var main: NSStoryboard? {
        guard let mainStoryboardName = Bundle.main.infoDictionary?["NSMainStoryboardFile"] as? String else {
            return nil
        }
        return NSStoryboard(name: NSStoryboard.Name(mainStoryboardName), bundle: .main)
    }
}
