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

public final class LyricsKugou: LyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    public func cancelSearch() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
    
    public func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        let keyword = criteria.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let mDuration = Int(duration * 1000)
        let urlStr = "http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=\(encodedKeyword)&duration=\(mDuration)"
        let url = URL(string: urlStr)!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data else {
                return
            }
            JSON(data)["candidates"].array?.enumerated().forEach { index, json in
                guard let id = json["id"].string, let accesskey = json["accesskey"].string else {
                    return
                }
                self.fetchLyrics(id: id, accesskey: accesskey) { lrc in
                    lrc.idTags[.title] = json["song"].string
                    lrc.idTags[.artist] = json["singer"].string
                    lrc.idTags[.lrcBy] = "Kugou"
                    
                    lrc.metadata.source = .Kugou
                    lrc.metadata.searchIndex = index
                    lrc.metadata.searchBy = criteria
                    
                    using(lrc)
                }
            }
        }
        task.resume()
        dispatchGroup.notify(queue: .global(), execute: completionHandler)
    }
    
    private func fetchLyrics(id: String, accesskey: String, completionBlock: @escaping (Lyrics) -> Void) {
        let urlStr = "http://lyrics.kugou.com/download?ver=1&client=pc&id=\(id)&accesskey=\(accesskey)&fmt=lrc&charset=utf8"
        let url = URL(string: urlStr)!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data else {
                return
            }
            guard let lrcDataStr = JSON(data)["content"].string,
                let lrcData = Data(base64Encoded: lrcDataStr),
                let lrcContent = String(data: lrcData, encoding: .utf8),
                let lrc = Lyrics(lrcContent) else {
                    return
            }
            completionBlock(lrc)
        }
        task.resume()
    }
}
