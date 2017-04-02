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
    var cacheImages = [URL: NSImage]()
    
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
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lyricsPreviewTextView: NSTextView!
    
    @IBOutlet weak var hideLrcPreviewConstraint: NSLayoutConstraint?
    @IBOutlet var normalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        lyricsHelper.delegate = self
        let helper = appDelegate()?.mediaPlayerHelper
        normalConstraint.isActive = false
        searchArtist = helper?.player?.currentTrack?.artist ?? ""
        searchTitle = helper?.player?.currentTrack?.name ?? ""
        searchAction(nil)
        super.viewDidLoad()
    }
    
    @IBAction func searchAction(_ sender: Any?) {
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
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
        appDelegate()?.mediaPlayerHelper.currentLyrics = lrc
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
        DispatchQueue.main.async {
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true
        }
    }
    
    // MARK: - TableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let ident = tableColumn?.identifier else {
            return nil
        }
        
        switch ident {
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = tableView.selectedRow
        guard index >= 0 else {
            return
        }
        if self.hideLrcPreviewConstraint?.isActive == true {
            self.expansionPreview()
        }
        self.lyricsPreviewTextView.string = self.searchResult[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
        self.updateImage()
    }
    
    func expansionPreview() {
        let expandingHeight = -view.subviews.reduce(0) { min($0, $1.frame.minY) }
        var windowFrame = self.view.window!.frame
        windowFrame.size.height += expandingHeight
        windowFrame.origin.y -= expandingHeight
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.33
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.1, 0.2, 1)
            self.hideLrcPreviewConstraint?.animator().isActive = false
            view.window?.setFrame(windowFrame, display: true, animate: true)
            self.view.needsUpdateConstraints = true
            self.view.needsLayout = true
            self.view.layoutSubtreeIfNeeded()
        }) {
            self.normalConstraint.isActive = true
        }
    }
    
    func updateImage() {
        let index = tableView.selectedRow
        guard index >= 0 else {
            return
        }
        guard let urlStr = self.searchResult[index].metadata[.artworkURL],
            let url = URL(string: urlStr) else {
            artworkView.image = #imageLiteral(resourceName: "missing_artwork")
            return
        }
        
        if let cacheImage = cacheImages[url] {
            artworkView.image = cacheImage
            return
        }
        
        artworkView.image = #imageLiteral(resourceName: "missing_artwork")
        DispatchQueue.global().async {
            self.cacheImages[url] = NSImage(contentsOf: url)
            DispatchQueue.main.async {
                self.updateImage()
            }
        }
    }
    
}
