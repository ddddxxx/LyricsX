//
//  IBInspection.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa

// These trait can be customized with Interface Builder.

extension NSMenuItem {
    
    @IBInspectable
    var isHiddenInMASVersion: Bool {
        get { return true }
        set {
            #if IS_FOR_MAS
            if newValue, isFromMacAppStore {
                isHidden = true
            }
            #endif
        }
    }
    
    @IBInspectable
    var isHiddenDuringMASReview: Bool {
        get { return true }
        set {
            #if IS_FOR_MAS
            if newValue, defaults[.isInMASReview] != false {
                isHidden = true
            }
            #endif
        }
    }
}

extension NSView {
    
    @IBInspectable
    var isRemovedDuringMASReview: Bool {
        get { return true }
        set {
            #if IS_FOR_MAS
            if newValue, defaults[.isInMASReview] != false {
                removeFromSuperview()
            }
            #endif
        }
    }
}
