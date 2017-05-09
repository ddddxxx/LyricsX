//
//  PreferenceFilterViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/20.
//
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

class PreferenceFilterViewController: NSViewController {
    
    dynamic var directFilter = [FilterKey]()
    dynamic var colonFilter = [FilterKey]()
    
    override func viewDidLoad() {
        loadFilter()
    }
    
    override func viewWillDisappear() {
        saveFilter()
    }
    
    func loadFilter() {
        directFilter = defaults[.LyricsDirectFilterKey].map() {
            FilterKey(keyword: $0)
        }
        colonFilter = defaults[.LyricsColonFilterKey].map() {
            FilterKey(keyword: $0)
        }
    }
    
    func saveFilter() {
        defaults[.LyricsDirectFilterKey] = directFilter.map() { $0.keyword }
        defaults[.LyricsColonFilterKey] = colonFilter.map() { $0.keyword }
    }
    
    @IBAction func resetFilterKey(_ sender: Any) {
        defaults.remove(.LyricsDirectFilterKey)
        defaults.remove(.LyricsColonFilterKey)
        loadFilter()
    }
    
}

@objc(FilterKey)
class FilterKey: NSObject, NSCoding {
    
    var keyword = ""
    
    override init() {
        keyword = NSLocalizedString("NEW_KEYWORD", comment: "")
        super.init()
    }
    
    init(keyword: String) {
        self.keyword = keyword
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let decodeKey = aDecoder.decodeObject(forKey: "keyword") as? String else {
            return nil
        }
        keyword = decodeKey
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(keyword, forKey: "keyword")
    }
}
