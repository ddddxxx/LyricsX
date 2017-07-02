//
//  LyricsQQ.swift
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
    static let QQMusic = Lyrics.MetaData.Source("QQMusic")
}

public final class LyricsQQ: LyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    public func cancel() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
    
    public func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        let keyword = criteria.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let urlString = "http://s.music.qq.com/fcgi-bin/music_search_new_platform?t=0&n=10&aggr=1&cr=1&loginUin=0&format=json&inCharset=GB2312&outCharset=utf-8&notice=0&platform=jqminiframe.json&needNewCode=0&p=1&catZhida=0&remoteplace=sizer.newclient.next_song&w=\(encodedKeyword)"
        let url = URL(string: urlString)!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data else {
                return
            }
            let ids = JSON(data)["data"]["song"]["list"].array?.flatMap { (item: JSON) -> Int? in
                guard let f = item["f"].string,
                    let range = f.range(of: "|") else {
                    return nil
                }
                return Int(f.substring(to: range.lowerBound))
            }
            ids?.enumerated().forEach { index, id in
                self.fetchLyrics(id: id) { lrc in
                    lrc.metadata.source = .QQMusic
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    lrc.metadata.artworkURL = URL(string: "http://imgcache.qq.com/music/photo/album/\(id % 100)/\(id).jpg")
                    
                    using(lrc)
                }
            }
        }
        task.resume()
        dispatchGroup.notify(queue: .global(), execute: completionHandler)
    }
    
    private func fetchLyrics(id: Int, completionBlock: @escaping (Lyrics) -> Void) {
        let url = URL(string: "http://music.qq.com/miniportal/static/lyric/\(id%100)/\(id).xml")!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            let parser = LyricsQQXMLParser()
            guard let data = data else {
                return
            }
            guard let lrcContent = parser.parseLrcContents(data: data),
                let lrc = Lyrics(lrcContent) else {
                return
            }
            completionBlock(lrc)
        }
        task.resume()
    }
}

private class LyricsQQXMLParser: NSObject, XMLParserDelegate {
    
    var lrcContents: String?
    
    override init() {
        super.init()
    }
    
    func parseLrcContents(data:Data) -> String? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success: Bool = parser.parse()
        if !success {
            return nil
        }
        return lrcContents?.htmlDecoded()
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        lrcContents = String(data: CDATABlock, encoding: .utf8)
    }
}

extension String {
    
    static let entities = [
        "&quot;"    : "\"",
        "&amp;"     : "&",
        "&apos;"    : "'",
        "&lt;"      : "<",
        "&gt;"      : ">",
    ]
    
    func htmlDecoded()->String {
        return String.entities.reduce(self) { str, entitie in
            str.replacingOccurrences(of: entitie.key, with: entitie.value)
        }
    }
}
