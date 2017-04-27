//
//  SearchLyricsViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/18.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, LyricsConsuming {
    
    var searchResult: [Lyrics] = []
    var imageCache = NSCache<NSURL, NSImage>()
    
    dynamic var searchArtist = ""
    dynamic var searchTitle = "" {
        didSet {
            searchButton.isEnabled = searchTitle.characters.count > 0
        }
    }
    dynamic var selectedIndex = NSIndexSet()
    
    let lyricsManager = LyricsSourceManager()
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lyricsPreviewTextView: NSTextView!
    
    @IBOutlet weak var hideLrcPreviewConstraint: NSLayoutConstraint?
    @IBOutlet var normalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        lyricsManager.consumer = self
        tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        normalConstraint.isActive = false
        
        let track = MusicPlayerManager.shared.player?.currentTrack
        searchArtist = track?.artist ?? ""
        searchTitle = track?.name ?? ""
        searchAction(nil)
        
        super.viewDidLoad()
    }
    
    @IBAction func searchAction(_ sender: Any?) {
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = false
        searchResult = []
        tableView.reloadData()
        let track = MusicPlayerManager.shared.player?.currentTrack
        let duration = track?.duration ?? 0
        let criteria = Lyrics.MetaData.SearchCriteria.info(title: searchTitle, artist: searchArtist)
        lyricsManager.fetchLyrics(with: criteria, title: track?.name, artist: track?.artist, duration: duration)
    }
    
    @IBAction func useLyricsAction(_ sender: NSButton) {
        guard let index = tableView.selectedRowIndexes.first else {
            return
        }
        let lrc = searchResult[index]
        AppController.shared.setCurrentLyrics(lyrics: lrc)
    }
    
    // MARK: - LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        let index = searchResult.index(where: {$0 < lyrics}) ?? searchResult.count
        searchResult.insert(lyrics, at: index)
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
            return searchResult[row].metadata.source.rawValue
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
            self.expandPreview()
        }
        self.lyricsPreviewTextView.string = self.searchResult[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
        self.updateImage()
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let lrcContent = searchResult[rowIndexes.first!].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
        pboard.declareTypes([NSStringPboardType, NSFilesPromisePboardType], owner: self)
        pboard.setString(lrcContent, forType: NSStringPboardType)
        pboard.setPropertyList(["lrc"], forType: NSFilesPromisePboardType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String] {
        return indexSet.flatMap { index -> String? in
            let fileName = searchResult[index].fileName
            
            let destURL = dropDestination.appendingPathComponent(fileName)
            let lrcStr = searchResult[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
            
            do {
                try lrcStr.write(to: destURL, atomically: true, encoding: .utf8)
            } catch let error as NSError{
                print(error)
                return nil
            }
            
            return fileName
        }
    }
    
    func expandPreview() {
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
        guard let url = self.searchResult[index].metadata.artworkURL else {
            artworkView.image = #imageLiteral(resourceName: "missing_artwork")
            return
        }
        
        if let cacheImage = imageCache.object(forKey: url as NSURL) {
            artworkView.image = cacheImage
            return
        }
        
        artworkView.image = #imageLiteral(resourceName: "missing_artwork")
        DispatchQueue.global().async {
            guard let image = NSImage(contentsOf: url) else {
                return
            }
            self.imageCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                self.updateImage()
            }
        }
    }
    
}
