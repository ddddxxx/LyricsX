//
//  SearchLyricsViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/18.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var searchResult = [LXLyrics]()
    
    override func viewDidLoad() {
        searchResult = (NSApplication.shared().delegate as? AppDelegate)?.helper.lyricsHelper.lyrics ?? []
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let title = tableColumn?.title else {
            return nil
        }
        
        switch title {
        case "Title":
            return searchResult[row].metadata[.searchTitle]
        case "Artist":
            return searchResult[row].metadata[.searchArtist]
        case "Source":
            return searchResult[row].metadata[.source]
        default:
            return nil
        }
    }
    
}
