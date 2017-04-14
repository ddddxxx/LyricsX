//
//  LyricsQQ.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/21.
//  Copyright © 2017年 ddddxxx. All rights reserved.
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
        
        queue.addOperation {
            let qqIDs = self.searchQQIDFor(keyword: keyword)
            for (index, qqID) in qqIDs.enumerated() {
                self.queue.addOperation {
                    guard var lrc = self.lyricsFor(id: qqID) else {
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
        let convertedURLStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
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
