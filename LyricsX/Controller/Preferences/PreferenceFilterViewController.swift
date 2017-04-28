//
//  PreferenceFilterViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/20.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
        directFilter = Preference[.LyricsDirectFilterKey]?.map() {
            FilterKey(keyword: $0)
        } ?? []
        colonFilter = Preference[.LyricsColonFilterKey]?.map() {
            FilterKey(keyword: $0)
        } ?? []
    }
    
    func saveFilter() {
        Preference[.LyricsDirectFilterKey] = directFilter.map() { $0.keyword }
        Preference[.LyricsColonFilterKey] = colonFilter.map() { $0.keyword }
    }
    
    @IBAction func resetFilterKey(_ sender: Any) {
        Preference[.LyricsDirectFilterKey] = nil
        Preference[.LyricsColonFilterKey] = nil
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
