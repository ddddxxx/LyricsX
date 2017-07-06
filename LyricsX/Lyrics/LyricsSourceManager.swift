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

public class LyricsSourceManager {
    
    public weak var consumer: LyricsConsuming?
    
    private var dispatchGroup = DispatchGroup()
    let lyricsSource: [LyricsSource] = [
        LyricsXiami(),
        LyricsGecimi(),
        LyricsTTPod(),
        Lyrics163(),
        LyricsQQ(),
        LyricsKugou(),
    ]
    
    public var criteria: Lyrics.MetaData.SearchCriteria?
    
    public var lyrics: [Lyrics] = []
    
    fileprivate func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, title: String?, artist: String?, duration: TimeInterval) {
        self.criteria = criteria
        lyrics = []
        lyricsSource.forEach { $0.cancelSearch() }
        lyricsSource.forEach { source in
            dispatchGroup.enter()
            source.searchLyrics(criteria: criteria, duration: duration, using: { lrc in
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
    
    fileprivate func iFeelLucky(criteria: Lyrics.MetaData.SearchCriteria, title: String?, artist: String?, duration: TimeInterval) {
        self.criteria = criteria
        lyrics = []
        lyricsSource.forEach { $0.cancelSearch() }
        lyricsSource.forEach { source in
            dispatchGroup.enter()
            source.iFeelLucky(criteria: criteria, duration: duration) {
                defer {
                    self.dispatchGroup.leave()
                }
                if let lrc = $0 {
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
                }
            }
        }
    }
}

extension LyricsSourceManager {
    
    public func searchLyrics(keyword: String? = nil, title: String, artist: String, duration: TimeInterval) {
        let criteria: Lyrics.MetaData.SearchCriteria
        if let keyword = keyword {
            criteria = .keyword(keyword)
        } else {
            criteria = .info(title: title, artist: artist)
        }
        searchLyrics(criteria: criteria, title: title, artist: artist, duration: duration)
    }
    
    public func iFeelLucky(keyword: String? = nil, title: String, artist: String, duration: TimeInterval) {
        let criteria: Lyrics.MetaData.SearchCriteria
        if let keyword = keyword {
            criteria = .keyword(keyword)
        } else {
            criteria = .info(title: title, artist: artist)
        }
        iFeelLucky(criteria: criteria, title: title, artist: artist, duration: duration)
    }
    
}

