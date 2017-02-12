//
//  LyricsGecimi.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsGecimi: LyricsSource {
    
    private let queue: OperationQueue
    
    init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String) -> [LXLyrics] {
        var result = [LXLyrics]()
        let lrcs = searchLrcFor(title: title, artist: artist)
        let fetchOps = lrcs.map() { url in
            return BlockOperation() {
                var metadata: [LXLyrics.metadataKey: Any] = [:]
                metadata[.source] = "Gecimi"
                metadata[.lyricsURL] = url
                if let lrc = LXLyrics(metadata: metadata) {
                    result += [lrc]
                }
            }
        }
        queue.addOperations(fetchOps, waitUntilFinished: true)
        return result
    }
    
    private func searchLrcFor(title: String, artist: String) -> [URL] {
        let urlStr = "http://gecimi.com/api/lyric/\(title)/\(artist)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["result"].array else {
            return []
        }
        
        return array.flatMap() { item in
            return item["lrc"].string.flatMap() {URL(string: $0)}
        }
    }

}
