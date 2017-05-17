//
//  LyricsTTPod.swift
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
    static let TTPod = Lyrics.MetaData.Source("TTPod")
}

class LyricsTTPod: LyricsSource {
    
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
            let urlStr = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=\(encodedArtist)&title=\(encodedTitle)"
            let url = URL(string: urlStr)!
            
            guard let data = try? Data(contentsOf: url),
                let lrcContent = JSON(data)["data"]["lrc"].string,
                var lrc = Lyrics(lrcContent)else {
                    return
            }
            
            lrc.metadata.source = .TTPod
            lrc.metadata.searchBy = criteria
            lrc.metadata.searchIndex = 0
            
            completionBlock(lrc)
        }
    }
}
