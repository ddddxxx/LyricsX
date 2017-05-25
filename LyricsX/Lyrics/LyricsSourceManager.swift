//
//  LyricsSourceHelper.swift
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
        lyricsSource.forEach { source in
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
