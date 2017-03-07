//
//  LyricsSourceHelper.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

protocol LyricsSourceDelegate {
    
    func lyricsReceived(lyrics: LXLyrics)
    
    func fetchCompleted(result: [LXLyrics])
    
}

protocol LyricsSource {
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (LXLyrics) -> Void)
    
    func cancelFetching()
    
}

class LyricsSourceHelper {
    
    var delegate: LyricsSourceDelegate?
    
    private let lyricsSource: [LyricsSource]
    private let queue: OperationQueue
    
    var searchTitle: String?
    var searchArtist: String?
    
    var lyrics: [LXLyrics]
    
    init() {
        queue = OperationQueue()
        lyricsSource = [
            LyricsXiami(queue: queue),
            LyricsGecimi(queue: queue),
            LyricsTTPod(queue: queue)
        ]
        lyrics = []
    }
    
    func fetchLyrics(title: String, artist: String) {
        searchTitle = title
        searchArtist = artist
        lyrics = []
        lyricsSource.forEach() { source in
            source.cancelFetching()
            source.fetchLyrics(title: title, artist: artist) { lrc in
                guard self.searchTitle == title, self.searchArtist == artist else {
                    return
                }
                self.lyrics += [lrc]
                self.delegate?.lyricsReceived(lyrics: lrc)
            }
            DispatchQueue.global(qos: .background).async {
                self.queue.waitUntilAllOperationsAreFinished()
                self.delegate?.fetchCompleted(result: self.lyrics)
            }
        }
    }
    
    func readLocalLyrics(title: String, artist: String) -> LXLyrics? {
        let savingPath: String
        if UserDefaults.standard.integer(forKey: LyricsSavingPathPopUpIndex) == 0 {
            savingPath = LyricsSavingPathDefault
        } else {
            savingPath = UserDefaults.standard.string(forKey: LyricsCustomSavingPath)!
        }
        let titleForReading: String = title.replacingOccurrences(of: "/", with: "&")
        let artistForReading: String = artist.replacingOccurrences(of: "/", with: "&")
        let lrcFilePath = (savingPath as NSString).appendingPathComponent("\(titleForReading) - \(artistForReading).lrc")
        if let lrcContents = try? String(contentsOfFile: lrcFilePath, encoding: String.Encoding.utf8) {
            var lrc = LXLyrics(lrcContents)
            let metadata: [LXLyrics.MetadataKey: String] = [
                .searchTitle: title,
                .searchArtist: artist,
                .source: "Local"
            ]
            lrc?.metadata = metadata
            return lrc
        }
        return nil
    }
    
}
