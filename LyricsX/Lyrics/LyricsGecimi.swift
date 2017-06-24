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

final class LyricsGecimi: LyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    func cancel() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
    
    func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        guard case let .info(title, artist) = criteria else {
            // cannot search by keyword
            return
        }
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        
        let url = URL(string: "http://gecimi.com/api/lyric/\(encodedTitle)/\(encodedArtist)")!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data else {
                return
            }
            JSON(data)["result"].array?.enumerated().forEach { index, item in
                guard let lrcURL = item["lrc"].url,
                    // FIXME: use URLSession instead of contentsOfURL
                    let lrc = Lyrics(url: lrcURL) else {
                    return
                }
                lrc.metadata.source = .Gecimi
                lrc.metadata.searchBy = criteria
                lrc.metadata.searchIndex = index
                if let aid = item["aid"].string,
                    let url = URL(string:"http://gecimi.com/api/cover/\(aid)") {
                    self.dispatchGroup.enter()
                    let task = self.session.dataTask(with: req) { data, resp, error in
                        defer {
                            self.dispatchGroup.leave()
                        }
                        // FIXME: contentsOf
                        if let data = try? Data(contentsOf: url),
                            let artworkURL = JSON(data)["result"]["cover"].url {
                            lrc.metadata.artworkURL = artworkURL
                        }
                    }
                }
                using(lrc)
            }
        }
        task.resume()
        dispatchGroup.notify(queue: .global(), execute: completionHandler)
    }
}
