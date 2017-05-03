//
//  LyricsXiami.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let Xiami = Lyrics.MetaData.Source("Xiami")
}

class LyricsXiami: LyricsSource {
    
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
            let xiamiIDs = self.searchXiamiIDFor(keyword: encodedKeyword)
            for (index, xiamiID) in xiamiIDs.enumerated() {
                self.queue.addOperation {
                    let parser = LyricsXiamiXMLParser()
                    guard let url = URL(string: "http://www.xiami.com/song/playlist/id/\(xiamiID)"),
                        let data = try? Data(contentsOf: url),
                        let parseResult = parser.parseLrcURL(data: data),
                        var lrc = Lyrics(url: parseResult.lyricsURL) else {
                            return
                    }
                    lrc.metadata.source = .Xiami
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    lrc.metadata.artworkURL = parseResult.artworkURL
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchXiamiIDFor(keyword: String) -> [Int] {
        let urlStr = "http://www.xiami.com/web/search-songs?key=" + keyword
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data).array else {
            return []
        }
        
        return array.flatMap() { item in
            return item["id"].string.flatMap() {Int($0)}
        }
    }
}

// MARK: - XMLParser

private class LyricsXiamiXMLParser: NSObject, XMLParserDelegate {
    
    var XMLContent: String?
    
    var lyricsURL: URL?
    var artworkURL: URL?
    
    func parseLrcURL(data: Data) -> (lyricsURL: URL, artworkURL: URL?)? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        guard let lyricsURL = lyricsURL else {
            return nil
        }
        
        return (lyricsURL, artworkURL)
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "lyric":
            lyricsURL = XMLContent.flatMap { URL(string: $0) }
        case "pic":
            artworkURL = XMLContent.flatMap { URL(string: $0) }
        default:
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
}
