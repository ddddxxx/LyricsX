//
//  LyricsSourceHelper.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

class LyricsSourceManager {
    
    weak var consumer: LyricsConsuming?
    
    private let lyricsSource: [LyricsSource]
    private let queue: OperationQueue
    
    var searchTitle: String?
    var searchArtist: String?
    
    var lyrics: [Lyrics]
    
    init() {
        queue = OperationQueue()
        lyricsSource = [
            LyricsXiami(queue: queue),
            LyricsGecimi(queue: queue),
            LyricsTTPod(queue: queue),
            Lyrics163(queue: queue),
            LyricsQQ(queue: queue),
            LyricsKugou(queue: queue),
        ]
        lyrics = []
    }
    
    func fetchLyrics(title: String, artist: String, duration: TimeInterval) {
        searchTitle = title
        searchArtist = artist
        lyrics = []
        queue.cancelAllOperations()
        lyricsSource.forEach() { source in
            source.fetchLyrics(title: title, artist: artist, duration: duration) { lrc in
                guard self.searchTitle == title, self.searchArtist == artist else {
                    return
                }
                let index = self.lyrics.index(where: {$0 < lrc}) ?? self.lyrics.count
                self.lyrics.insert(lrc, at: index)
                self.consumer?.lyricsReceived(lyrics: lrc)
            }
            DispatchQueue.global(qos: .background).async {
                self.queue.waitUntilAllOperationsAreFinished()
                self.consumer?.fetchCompleted(result: self.lyrics)
            }
        }
    }
}
