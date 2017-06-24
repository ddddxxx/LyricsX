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
    
    private var dispatchGroup = DispatchGroup()
    let lyricsSource: [LyricsSource] = [
        LyricsXiami(),
        LyricsGecimi(),
        LyricsTTPod(),
        Lyrics163(),
        LyricsQQ(),
        LyricsKugou(),
    ]
    
    var criteria: Lyrics.MetaData.SearchCriteria?
    
    var lyrics: [Lyrics] = []
    
    func fetchLyrics(title: String, artist: String, duration: TimeInterval) {
        fetchLyrics(with: .info(title: title, artist: artist), title: title, artist: artist, duration: duration)
    }
    
    func fetchLyrics(with criteria: Lyrics.MetaData.SearchCriteria, title: String?, artist: String?, duration: TimeInterval) {
        self.criteria = criteria
        lyrics = []
        lyricsSource.forEach { $0.cancel() }
        lyricsSource.forEach { source in
            dispatchGroup.enter()
            source.fetchLyrics(by: criteria, duration: duration, using: { lrc in
                guard self.criteria == criteria else {
                    return
                }
                
                lrc.metadata.title = title
                lrc.metadata.artist = artist
                lrc.idTags[.recreater] = "LyricsX"
                lrc.idTags[.version] = "1"
                
                let index = self.lyrics.index(where: {$0 < lrc}) ?? self.lyrics.count
                self.lyrics.insert(lrc, at: index)
                self.consumer?.lyricsReceived(lyrics: lrc)
            }, completionHandler: {
                self.dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .global()) {
            self.consumer?.fetchCompleted(result: self.lyrics)
        }
    }
}
