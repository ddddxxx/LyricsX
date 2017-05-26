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

class LyricsQQ: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
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
        
        queue.addOperation {
            let qqIDs = self.searchQQIDFor(keyword: encodedKeyword)
            for (index, qqID) in qqIDs.enumerated() {
                self.queue.addOperation {
                    guard let lrc = self.lyricsFor(id: qqID) else {
                        return
                    }
                    
                    lrc.metadata.source = .QQMusic
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    lrc.metadata.artworkURL = URL(string: "http://imgcache.qq.com/music/photo/album/\(qqID%100)/\(qqID).jpg")
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchQQIDFor(keyword: String) -> [Int] {
        let urlString: String = "http://s.music.qq.com/fcgi-bin/music_search_new_platform?t=0&n=10&aggr=1&cr=1&loginUin=0&format=json&inCharset=GB2312&outCharset=utf-8&notice=0&platform=jqminiframe.json&needNewCode=0&p=1&catZhida=0&remoteplace=sizer.newclient.next_song&w=\(keyword)"
        let url = URL(string: urlString)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["data"]["song"]["list"].array else {
            return []
        }
        
        return array.flatMap { item in
            guard let f = item["f"].string,
                let range = f.range(of: "|") else {
                return nil
            }
            return Int(f.substring(to: range.lowerBound))
        }
    }
    
    private func lyricsFor(id: Int) -> Lyrics? {
        let url = URL(string: "http://music.qq.com/miniportal/static/lyric/\(id%100)/\(id).xml")!
        let parser = LyricsQQXMLParser()
        guard let lrcData = try? Data(contentsOf: url),
            let lrcContent = parser.parseLrcContents(data: lrcData) else {
            return nil
        }
        return Lyrics(lrcContent)
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
