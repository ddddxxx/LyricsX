//
//  SearchLyricsViewController.swift
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
import LyricsProvider

class SearchLyricsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, LyricsConsuming {
    
    var imageCache = NSCache<NSURL, NSImage>()
    
    dynamic var searchArtist = ""
    dynamic var searchTitle = "" {
        didSet {
            searchButton.isEnabled = searchTitle.characters.count > 0
        }
    }
    dynamic var selectedIndex = NSIndexSet()
    
    let lyricsManager = LyricsProviderManager()
    
    @IBOutlet weak var artworkView: NSImageView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet var lyricsPreviewTextView: NSTextView!
    
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
        let track = MusicPlayerManager.shared.player?.currentTrack
        let duration = track?.duration ?? 0
        let title = track?.name ?? ""
        let artist = track?.artist ?? ""
        lyricsManager.searchLyrics(searchTitle: searchTitle, searchArtist: searchArtist, title: title, artist: artist, duration: duration)
        tableView.reloadData()
    }
    
    @IBAction func useLyricsAction(_ sender: NSButton) {
        guard let index = tableView.selectedRowIndexes.first else {
            return
        }
        
        if let id = MusicPlayerManager.shared.player?.currentTrack?.id,
            let i = defaults[.NoSearchingTrackIds].index(where: { $0 == id }) {
            defaults[.NoSearchingTrackIds].remove(at: i)
        }
        
        let lrc = lyricsManager.lyrics[index]
        AppController.shared.currentLyrics = lrc
    }
    
    // MARK: - LyricsSourceDelegate
    
    func lyricsReceived(lyrics: Lyrics) {
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
        return lyricsManager.lyrics.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let ident = tableColumn?.identifier else {
            return nil
        }
        
        switch ident {
        case "Title":
            return lyricsManager.lyrics[row].idTags[.title] ?? "[lacking]"
        case "Artist":
            return lyricsManager.lyrics[row].idTags[.artist] ?? "[lacking]"
        case "Source":
            return lyricsManager.lyrics[row].metadata.source.rawValue
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
        self.lyricsPreviewTextView.string = self.lyricsManager.lyrics[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
        self.updateImage()
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let lrcContent = lyricsManager.lyrics[rowIndexes.first!].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
        pboard.declareTypes([NSStringPboardType, NSFilesPromisePboardType], owner: self)
        pboard.setString(lrcContent, forType: NSStringPboardType)
        pboard.setPropertyList(["lrc"], forType: NSFilesPromisePboardType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String] {
        return indexSet.flatMap { index -> String? in
            let fileName = lyricsManager.lyrics[index].fileName ?? "Unknown"
            
            let destURL = dropDestination.appendingPathComponent(fileName)
            let lrcStr = lyricsManager.lyrics[index].contentString(withMetadata: false, ID3: true, timeTag: true, translation: true)
            
            do {
                try lrcStr.write(to: destURL, atomically: true, encoding: .utf8)
            } catch {
                log(error.localizedDescription)
                return nil
            }
            
            return fileName
        }
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
        guard let url = self.lyricsManager.lyrics[index].metadata.artworkURL else {
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
