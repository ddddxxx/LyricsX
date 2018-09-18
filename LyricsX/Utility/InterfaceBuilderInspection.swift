//
//  InterfaceBuilderInspection.swift
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

extension NSMenuItem {
    
    @IBInspectable
    var isHiddenInMASVersion: Bool {
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
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
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
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
        get {
            // fake getter. we only need its setter in IB.
            return true
        }
        set {
            #if IS_FOR_MAS
            if newValue, defaults[.isInMASReview] != false {
                removeFromSuperview()
            }
            #endif
        }
    }
}
