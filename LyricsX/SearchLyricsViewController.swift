//
//  SearchLyricsViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/18.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, LyricsSourceDelegate {
    
    var searchResult = [Lyrics]()
    
    dynamic var searchArtist = ""
    dynamic var searchTitle = "" {
        didSet {
            searchButton.isEnabled = searchTitle.characters.count > 0
        }
    }
    dynamic var selectedIndex = NSIndexSet()
    
    let lyricsHelper = LyricsSourceHelper()
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var lyricsPreviewTextView: NSTextView!
    
    override func viewDidLoad() {
        lyricsHelper.delegate = self
        let helper = (NSApplication.shared().delegate as? AppDelegate)?.helper
        searchArtist = helper?.iTunes.currentTrack?.artist as String? ?? ""
        searchTitle = helper?.iTunes.currentTrack?.name as String? ?? ""
        searchResult = helper?.lyricsHelper.lyrics ?? []
        super.viewDidLoad()
    }
    
    @IBAction func searchAction(_ sender: NSButton) {
        searchResult = []
        tableView.reloadData()
        lyricsHelper.fetchLyrics(title: searchTitle, artist: searchArtist)
    }
    
    
    @IBAction func useLyricsAction(_ sender: NSButton) {
        guard let index = tableView.selectedRowIndexes.first else {
            return
        }
        var lrc = searchResult[index]
        lrc.filtrate()
        appDelegate.helper.currentLyrics = lrc
        lrc.saveToLocal()
    }
    
    // MARK: - LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        searchResult += [lyrics]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchCompleted(result: [Lyrics]) {
        
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
            return searchResult[row].idTags[.title] ?? "[lacking]"
        case "Artist":
            return searchResult[row].idTags[.artist] ?? "[lacking]"
        case "Source":
            return searchResult[row].metadata[.source]
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if proposedSelectionIndexes.count == 1,
            let index = proposedSelectionIndexes.first {
            lyricsPreviewTextView.string = searchResult[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
            artworkView.image = searchResult[index].metadata[.artworkURL].flatMap({URL(string: $0)}).flatMap({NSImage(contentsOf: $0)}) ?? #imageLiteral(resourceName: "missing_artwork")
        }
        
        return proposedSelectionIndexes;
    }
    
}
