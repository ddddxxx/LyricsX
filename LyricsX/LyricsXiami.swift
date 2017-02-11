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
    
    init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String) -> [LXLyrics] {
        var result = [LXLyrics]()
        let xiamiIDs = searchXiamiIDFor(title: title, artist: artist)
        let fetchOps = xiamiIDs.map() { id in
            return BlockOperation() {
                if let url = self.searchLrcFor(xiamiID: id) {
                    var metadata: [LXLyrics.metadataKey: Any] = [:]
                    metadata[.source] = "Xiami"
                    metadata[.lyricsURL] = url
                    if let lrc = LXLyrics(metadata: metadata) {
                        result += [lrc]
                    }
                }
            }
        }
        queue.addOperations(fetchOps, waitUntilFinished: true)
        return result
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
    
    private func searchLrcFor(xiamiID: Int) -> URL? {
        let parser = LyricsXiamiXMLParser()
        guard let url = URL(string: "http://www.xiami.com/song/playlist/id/\(xiamiID)"),
            let data = try? Data(contentsOf: url),
            let urlStr = parser.parseLrcURL(data: data) else {
            return nil
        }
        
        return URL(string: urlStr)
    }
    
}

// MARK: - XMLParser

private class LyricsXiamiXMLParser: NSObject, XMLParserDelegate {
    
    var XMLContent: String?
    
    var lrcResult: String?
    
    func parseLrcURL(data: Data) -> String? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        return success ? lrcResult : nil
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "lyric" {
            lrcResult = XMLContent
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
    
}
