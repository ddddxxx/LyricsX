//
//  LyricsKugou.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsKugou: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void) {
        let mDuration = Int(duration * 1000)
        queue.addOperation {
            let searchItems = self.searchKugouIDFor(title: title, artist: artist, duration: mDuration)
            for (index, searchItem) in searchItems.enumerated() {
                self.queue.addOperation {
                    guard var lrc = self.lyricsFor(searchItem) else {
                        return
                    }
                    var metadata: [Lyrics.MetadataKey: Any] = [:]
                    metadata[.source]       = "Kugou"
                    metadata[.searchTitle]  = title
                    metadata[.searchArtist] = artist
                    metadata[.searchIndex]  = index
                    lrc.metadata = metadata
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchKugouIDFor(title: String, artist: String, duration: Int) -> [JSON] {
        let urlStr = "http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=\(title) \(artist)&duration=\(duration)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url) else {
            return []
        }
        
        return JSON(data)["candidates"].array ?? []
    }
    
    private func lyricsFor(_ item: JSON) -> Lyrics? {
        guard let id = item["id"].string, let accesskey = item["accesskey"].string else {
            return nil
        }
        let url = URL(string: "http://lyrics.kugou.com/download?ver=1&client=pc&id=\(id)&accesskey=\(accesskey)&fmt=lrc&charset=utf8")!
        guard let jsonData = try? Data(contentsOf: url),
            let lrcDataStr = JSON(jsonData)["content"].string,
            let lrcData = Data(base64Encoded: lrcDataStr),
            let lrcContent = String(data: lrcData, encoding: .utf8),
            var lrc = Lyrics(lrcContent) else {
            return nil
        }
        lrc.idTags[.title] = item["song"].string
        lrc.idTags[.artist] = item["singer"].string
        lrc.idTags[.lrcBy] = "Kugou"
        return lrc
    }
    
}
