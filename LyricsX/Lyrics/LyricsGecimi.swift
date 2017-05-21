//
//  LyricsGecimi.swift
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
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let Gecimi = Lyrics.MetaData.Source("Gecimi")
}

class LyricsGecimi: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void) {
        guard case let .info(title, artist) = criteria else {
            // cannot search by keyword
            return
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        queue.addOperation {
            let lrcDatas = self.searchLrcFor(title: encodedTitle, artist: encodedArtist)
            for (index, lrcData) in lrcDatas.enumerated() {
                self.queue.addOperation {
                    guard var lrc = Lyrics(url: lrcData.lyricsURL) else {
                        return
                    }
                    
                    lrc.metadata.source = .Gecimi
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    lrc.metadata.artworkURL = lrcData.artworkURL
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchLrcFor(title: String, artist: String) -> [(lyricsURL: URL, artworkURL: URL?)] {
        let urlStr = "http://gecimi.com/api/lyric/\(title)/\(artist)"
        let url = URL(string: urlStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["result"].array else {
            return []
        }
        
        return array.flatMap() { item in
            guard let lrcURL = item["lrc"].url else {
                return nil
            }
            
            if let aid = item["aid"].string,
                let url = URL(string:"http://gecimi.com/api/cover/\(aid)"),
                let data = try? Data(contentsOf: url),
                let artworkURL = JSON(data)["result"]["cover"].url {
                    return (lrcURL, artworkURL)
            }
            return (lrcURL, nil)
        }
    }
}
