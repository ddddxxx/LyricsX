//
//  LyricsKugou.swift
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
    static let Kugou = Lyrics.MetaData.Source("Kugou")
}

public final class LyricsKugou: MultiResultLyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping ([JSON]) -> Void) {
        let keyword = criteria.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let mDuration = Int(duration * 1000)
        let urlStr = "http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=\(encodedKeyword)&duration=\(mDuration)"
        let url = URL(string: urlStr)!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            let json = data.map(JSON.init)?["candidates"].array ?? []
            completionHandler(json)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: JSON, completionHandler: @escaping (Lyrics?) -> Void) {
        guard let id = token["id"].string, let accesskey = token["accesskey"].string else {
            completionHandler(nil)
            return
        }
        let urlStr = "http://lyrics.kugou.com/download?ver=1&client=pc&id=\(id)&accesskey=\(accesskey)&fmt=lrc&charset=utf8"
        let url = URL(string: urlStr)!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            guard let lrcDataStr = data.map(JSON.init)?["content"].string,
                let lrcData = Data(base64Encoded: lrcDataStr),
                let lrcContent = String(data: lrcData, encoding: .utf8),
                let lrc = Lyrics(lrcContent) else {
                completionHandler(nil)
                return
            }
            lrc.idTags[.title] = token["song"].string
            lrc.idTags[.artist] = token["singer"].string
            lrc.idTags[.lrcBy] = "Kugou"
            
            lrc.metadata.source = .Kugou
            
            completionHandler(lrc)
        }
        task.resume()
    }
}
