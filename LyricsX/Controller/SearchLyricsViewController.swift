//
//  SearchLyricsViewController.swift
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
import Crashlytics
import LyricsProvider
import MusicPlayer

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var imageCache = NSCache<NSURL, NSImage>()
    
    @objc dynamic var searchArtist = ""
    @objc dynamic var searchTitle = "" {
        didSet {
            searchButton.isEnabled = searchTitle.count > 0
        }
    }
    @objc dynamic var selectedIndex = NSIndexSet()
    
    let lyricsManager = LyricsProviderManager()
    var searchTask: LyricsSearchTask?
    var searchResult: [Lyrics] = []
    var progressObservation: NSKeyValueObservation?
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet var lyricsPreviewTextView: NSTextView!
    
    @IBOutlet weak var hideLrcPreviewConstraint: NSLayoutConstraint?
    @IBOutlet var normalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        normalConstraint.isActive = false
    }
    
    override func viewWillAppear() {
        guard let track = AppController.shared.playerManager.player?.currentTrack else {
            searchTask?.cancel()
            searchTask = nil
            searchResult = []
            searchArtist = ""
            searchTitle = ""
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
        searchTask?.cancel()
        searchResult = []
        
        let track = AppController.shared.playerManager.player?.currentTrack
        let duration = track?.duration ?? 0
        let title = track?.title ?? ""
        let artist = track?.artist ?? ""
        let req = LyricsSearchRequest(searchTerm: .info(title: searchTitle, artist: searchArtist),
                                      title: title,
                                      artist: artist,
                                      duration: duration,
                                      limit: 8,
                                      timeout: 10)
        let task = lyricsManager.searchLyrics(request: req, using: self.lyricsReceived)
        searchTask = task
        task.resume()
        progressIndicator.isHidden = false
        progressIndicator.doubleValue = 0
        progressObservation = task.progress.observe(\.fractionCompleted, options: [.new]) { [weak self] _, change in
            guard let fractionCompleted = change.newValue else { return }
            DispatchQueue.main.async {
                self?.progressIndicator.doubleValue = fractionCompleted
                if fractionCompleted == 1 {
                    self?.progressIndicator.isHidden = true
                }
            }
        }
        tableView.reloadData()
        Answers.logCustomEvent(withName: "Search Lyrics Manually")
    }
    
    @IBAction func useLyricsAction(_ sender: NSButton) {
        guard let index = tableView.selectedRowIndexes.first else {
            return
        }
        
        if let id = AppController.shared.playerManager.player?.currentTrack?.id,
            let index = defaults[.NoSearchingTrackIds].index(where: { $0 == id }) {
            defaults[.NoSearchingTrackIds].remove(at: index)
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
        guard lyrics.metadata.request == searchTask?.request else {
            return
        }
        if let idx = searchResult.index(where: { lyrics.quality > $0.quality }) {
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
            context.timingFunction = .mystery
            hideLrcPreviewConstraint?.animator().isActive = false
            view.window?.setFrame(windowFrame, display: true, animate: true)
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

extension NSUserInterfaceItemIdentifier {
    fileprivate static let searchResultColumnTitle = NSUserInterfaceItemIdentifier("Title")
    fileprivate static let searchResultColumnArtist = NSUserInterfaceItemIdentifier("Artist")
    fileprivate static let searchResultColumnSource = NSUserInterfaceItemIdentifier("Source")
}
