//
//  SearchLyricsViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import CombineX
import Crashlytics
import LyricsService
import MusicPlayer

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var imageCache = NSCache<NSURL, NSImage>()
    
    @objc dynamic var searchArtist = ""
    @objc dynamic var searchTitle = "" {
        didSet {
            searchButton.isEnabled = !searchTitle.isEmpty
        }
    }
    
    let lyricsManager = LyricsProviderManager()
    var searchRequest: LyricsSearchRequest?
    var searchCanceller: Cancellable?
    var searchResult: [Lyrics] = []
    var progressObservation: NSKeyValueObservation?
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    // NSTextView doesn't support weak references
    @IBOutlet var lyricsPreviewTextView: NSTextView!
    
    @IBOutlet weak var hideLrcPreviewConstraint: NSLayoutConstraint?
    @IBOutlet var normalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        normalConstraint.isActive = false
    }
    
    override func viewWillAppear() {
        self.reloadKeyword()
    }
    
    func reloadKeyword() {
        guard let track = selectedPlayer.currentTrack else {
            searchCanceller?.cancel()
            searchResult = []
            searchArtist = ""
            searchTitle = ""
            artworkView.image = #imageLiteral(resourceName: "missing_artwork")
            lyricsPreviewTextView.string = " "
            tableView.reloadData()
            return
        }
        let artist = track.artist ?? ""
        let title = track.title ?? ""
        if (searchArtist, searchTitle) != (artist, title) {
            (searchArtist, searchTitle) = (artist, title)
            searchAction(nil)
        }
    }
    
    @IBAction func searchAction(_ sender: Any?) {
        searchCanceller?.cancel()
        progressObservation?.invalidate()
        searchResult = []
        artworkView.image = #imageLiteral(resourceName: "missing_artwork")
        lyricsPreviewTextView.string = " "
        
        let track = selectedPlayer.currentTrack
        let duration = track?.duration ?? 0
        let title = track?.title ?? ""
        let artist = track?.artist ?? ""
        let req = LyricsSearchRequest(searchTerm: .info(title: searchTitle, artist: searchArtist),
                                      title: title,
                                      artist: artist,
                                      duration: duration,
                                      limit: 8,
                                      timeout: 10)
        searchRequest = req
        searchCanceller = lyricsManager.lyricsPublisher(request: req)
            .sink(receiveCompletion: { [unowned self] _ in
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimation(nil)
                }
            }, receiveValue: { [unowned self] lyrics in
                self.lyricsReceived(lyrics: lyrics)
            }).cancel(after: .seconds(10), scheduler: DispatchQueue.global().cx)
        progressIndicator.startAnimation(nil)
        tableView.reloadData()
        Answers.logCustomEvent(withName: "Search Lyrics Manually")
    }
    
    @IBAction func useLyricsAction(_ sender: Any) {
        guard let index = tableView.selectedRowIndexes.first else {
            return
        }
        
        if let track = selectedPlayer.currentTrack {
            if let index = defaults[.NoSearchingTrackIds].firstIndex(of: track.id) {
                defaults[.NoSearchingTrackIds].remove(at: index)
            }
            if let index = defaults[.NoSearchingAlbumNames].firstIndex(of: track.album ?? "") {
                defaults[.NoSearchingAlbumNames].remove(at: index)
            }
        }
        
        let lrc = searchResult[index]
        AppController.shared.currentLyrics = lrc
        if defaults[.WriteToiTunesAutomatically] {
            AppController.shared.writeToiTunes(overwrite: true)
        }
        Answers.logCustomEvent(withName: "Choose Search Result", customAttributes: ["index": index])
    }
    
    // MARK: - LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
        guard lyrics.metadata.request == searchRequest else {
            return
        }
        lyrics.filtrate()
        lyrics.recognizeLanguage()
        lyrics.metadata.needsPersist = true
        if let idx = searchResult.firstIndex(where: { lyrics.quality > $0.quality }) {
            searchResult.insert(lyrics, at: idx)
        } else {
            searchResult.append(lyrics)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        case .searchResultColumnTitle:
            return searchResult[row].idTags[.title] ?? "[lacking]"
        case .searchResultColumnArtist:
            return searchResult[row].idTags[.artist] ?? "[lacking]"
        case .searchResultColumnSource:
            return searchResult[row].metadata.source?.rawValue ?? "[lacking]"
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
        self.lyricsPreviewTextView.string = self.searchResult[index].description
        self.updateImage()
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let lrcContent = searchResult[rowIndexes.first!].description
        pboard.declareTypes([.string, .filePromise], owner: self)
        pboard.setString(lrcContent, forType: .string)
        pboard.setPropertyList(["lrc"], forType: .filePromise)
        return true
    }
    
    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String] {
        return indexSet.compactMap { index -> String? in
            let fileName = searchResult[index].fileName ?? "Unknown"
            
            let destURL = dropDestination.appendingPathComponent(fileName)
            let lrcStr = searchResult[index].description
            
            do {
                try lrcStr.write(to: destURL, atomically: true, encoding: .utf8)
            } catch {
                log(error.localizedDescription)
                return nil
            }
            
            return fileName
        }
    }
    
    // MARK: - NSTextFieldDelegate
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            searchAction(nil)
            return true
        }
        return false
    }
    
    private func expandPreview() {
        let expandingHeight = -view.subviews.reduce(0) { min($0, $1.frame.minY) }
        let windowFrame = self.view.window!.frame.with {
            $0.size.height += expandingHeight
            $0.origin.y -= expandingHeight
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.33
            context.allowsImplicitAnimation = true
            context.timingFunction = .swiftOut
            hideLrcPreviewConstraint?.animator().isActive = false
            view.window?.setFrame(windowFrame, display: false, animate: true)
            view.needsUpdateConstraints = true
            view.needsLayout = true
            view.layoutSubtreeIfNeeded()
        }, completionHandler: {
            self.normalConstraint.isActive = true
        })
    }
    
    private func updateImage() {
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
