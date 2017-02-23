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
    
    dynamic var searchArtist = ""
    dynamic var searchTitle = ""
    
    let lyricsHelper = LyricsSourceHelper()
    
    var hudWindow: NSWindowController!
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        let helper = (NSApplication.shared().delegate as? AppDelegate)?.helper
        searchArtist = helper?.currentArtist ?? ""
        searchTitle = helper?.currentSongTitle ?? ""
        searchResult = helper?.lyricsHelper.lyrics ?? []
        hudWindow = NSStoryboard(name: "Main", bundle: .main).instantiateController(withIdentifier: "LyricsHUD") as? NSWindowController
        super.viewDidLoad()
    }
    
    @IBAction func searchAction(_ sender: NSButton) {
        searchResult = []
        tableView.reloadData()
        guard searchTitle.characters.count > 0,
            searchArtist.characters.count > 0 else {
            // TODO: alert
            return
        }
        lyricsHelper.fetchLyrics(title: searchTitle, artist: searchArtist) {
            self.searchResult = self.lyricsHelper.lyrics
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableViewDelegate
    
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
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if proposedSelectionIndexes.count == 1,
            let index = proposedSelectionIndexes.first {
            let hudView = hudWindow.contentViewController as? LyricsHUDViewController
            hudView?.lyrics = searchResult[index]
            hudWindow.showWindow(nil)
            artworkView.image = searchResult[index].metadata[.artworkURL].flatMap({URL(string: $0)}).flatMap({NSImage(contentsOf: $0)}) ?? #imageLiteral(resourceName: "no_artwork")
            self.view.window?.makeKeyAndOrderFront(nil)
            tableView.becomeFirstResponder()
        }
        
        return proposedSelectionIndexes;
    }
    
}
