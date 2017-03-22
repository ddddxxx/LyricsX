//
//  LyricsXiami.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsXiami: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (Lyrics) -> Void) {
        queue.addOperation {
            let xiamiIDs = self.searchXiamiIDFor(title: title, artist: artist)
            xiamiIDs.forEach() { xiamiID in
                self.queue.addOperation {
                    let parser = LyricsXiamiXMLParser()
                    guard let url = URL(string: "http://www.xiami.com/song/playlist/id/\(xiamiID)"),
                        let data = try? Data(contentsOf: url),
                        var metadata = parser.parseLrcURL(data: data) else {
                            return
                    }
                    metadata[.source] = "Xiami"
                    metadata[.searchTitle] = title
                    metadata[.searchArtist] = artist
                    if let lrc = Lyrics(metadata: metadata) {
                        completionBlock(lrc)
                    }
                }
            }
        }
    }
    
    private func searchXiamiIDFor(title: String, artist: String) -> [Int] {
        let urlStr = "http://www.xiami.com/web/search-songs?key=\(title) \(artist)"
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
    
    var result: [Lyrics.MetadataKey: String] = [:]
    
    func parseLrcURL(data: Data) -> [Lyrics.MetadataKey: String]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        return success ? result : nil
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "lyric":
            result[.lyricsURL] = XMLContent
        case "pic":
            result[.artworkURL] = XMLContent
        default:
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
    
}
