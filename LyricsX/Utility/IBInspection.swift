//
//  IBInspection.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
