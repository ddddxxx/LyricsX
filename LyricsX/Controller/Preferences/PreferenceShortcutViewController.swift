//
//  PreferenceShortcutViewController.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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
import GenericID
import MASShortcut

class PreferenceShortcutViewController: NSViewController {
    
    @IBOutlet weak var shortcutIncreaseOffset: MASShortcutView!
    @IBOutlet weak var shortcutDecreaseOffset: MASShortcutView!
    @IBOutlet weak var shortcutWriteToiTunes: MASShortcutView!
    @IBOutlet weak var shortcutSearchLyrics: MASShortcutView!
    @IBOutlet weak var shortcutWrongLyrics: MASShortcutView!
    
    override func viewDidLoad() {
        shortcutIncreaseOffset.setAssociatedDefaultsKey(defaultKey: .ShortcutOffsetIncrease)
        shortcutDecreaseOffset.setAssociatedDefaultsKey(defaultKey: .ShortcutOffsetDecrease)
        shortcutWriteToiTunes.setAssociatedDefaultsKey(defaultKey: .ShortcutWriteToiTunes)
        shortcutSearchLyrics.setAssociatedDefaultsKey(defaultKey: .ShortcutSearchLyrics)
        shortcutWrongLyrics.setAssociatedDefaultsKey(defaultKey: .ShortcutWrongLyrics)
    }
    
}

extension MASShortcutView {
    
    func setAssociatedDefaultsKey<T>(defaultKey: UserDefaults.DefaultKey<T>) {
        associatedUserDefaultsKey = defaultKey.rawValue
    }
}
