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
    
    var criteria: Lyrics.MetaData.SearchCriteria?
    
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
        fetchLyrics(with: .info(title: title, artist: artist), title: title, artist: artist, duration: duration)
    }
    
    func fetchLyrics(with criteria: Lyrics.MetaData.SearchCriteria, title: String?, artist: String?, duration: TimeInterval) {
        self.criteria = criteria
        lyrics = []
        queue.cancelAllOperations()
        lyricsSource.forEach() { source in
            source.fetchLyrics(by: criteria, duration: duration) { lrc in
                guard self.criteria == criteria else {
                    return
                }
                
                var lrc = lrc
                lrc.metadata.title = title
                lrc.metadata.artist = artist
                
                let index = self.lyrics.index(where: {$0 < lrc}) ?? self.lyrics.count
                self.lyrics.insert(lrc, at: index)
                self.consumer?.lyricsReceived(lyrics: lrc)
            }
        }
        DispatchQueue.global(qos: .background).async {
            self.queue.waitUntilAllOperationsAreFinished()
            self.consumer?.fetchCompleted(result: self.lyrics)
        }
    }
}
