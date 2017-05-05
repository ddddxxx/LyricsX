//
//  Lyrics163.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/8.
//
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
    static let Music163 = Lyrics.MetaData.Source("163")
}

class Lyrics163: LyricsSource {
    
    let queue: OperationQueue
    private let session: URLSession
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
    }
    
    func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void) {
        let keyword: String
        switch criteria {
        case let .keyword(key):
            keyword = key
        case let .info(title, artist):
            keyword = title + " " + artist
        }
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let url = URL(string: "http://music.163.com/api/search/pc")!
        let body = "s=\(encodedKeyword)&offset=0&limit=10&type=1".data(using: .utf8)!
        
        var req = URLRequest(url: url)
        req.allHTTPHeaderFields = [
            "Cookie": "appver=1.5.0.75771;",
            "Referer": "http://music.163.com/",
        ]
        req.httpMethod = "POST"
        req.httpBody = body
        
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let array = JSON(data: data)["result"]["songs"].array else {
                    return
            }
            
            for (index, item) in array.enumerated() {
                self.queue.addOperation {
                    guard let id = item["id"].number?.intValue,
                        var lyrics = self.lyricsFor(id: id) else {
                            return
                    }
                    
                    lyrics.idTags[.title]   = item["name"].string
                    lyrics.idTags[.artist]  = item["artists"][0]["name"].string
                    lyrics.idTags[.album]   = item["album"]["name"].string
                    lyrics.idTags[.lrcBy]   = "163"
                    
                    lyrics.metadata.searchBy    = criteria
                    lyrics.metadata.searchIndex = index
                    lyrics.metadata.source      = .Music163
                    lyrics.metadata.artworkURL  = item["album"]["picUrl"].url
                    
                    completionBlock(lyrics)
                }
            }
        }
        task.resume()
    }
    
    private func lyricsFor(id: Int) -> Lyrics? {
        let url = URL(string: "http://music.163.com/api/song/lyric?id=\(id)&lv=1&kv=1&tv=-1")!
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let json = JSON(data: data)
        guard let lrcContent = json["lrc"]["lyric"].string,
            var lrc = Lyrics(lrcContent) else {
            return nil
        }
        
        if let transLrcContent = json["tlyric"]["lyric"].string,
            let transLrc = Lyrics(transLrcContent) {
            lrc.merge(translation: transLrc)
            lrc.metadata.includeTranslation = true
        }
        
        return lrc
    }
}

extension Lyrics {
    
    fileprivate mutating func merge(translation: Lyrics) {
        var index = lyrics.startIndex
        var transIndex = translation.lyrics.startIndex
        while index < lyrics.endIndex, transIndex < translation.lyrics.endIndex {
            if lyrics[index].position == translation.lyrics[transIndex].position {
                let transStr = translation.lyrics[transIndex].sentence
                if transStr.characters.count > 0 {
                    lyrics[index].translation = transStr
                }
                lyrics.formIndex(after: &index)
                translation.lyrics.formIndex(after: &transIndex)
            } else if lyrics[index].position > translation.lyrics[transIndex].position {
                translation.lyrics.formIndex(after: &transIndex)
            } else {
                lyrics.formIndex(after: &index)
            }
        }
    }
}
