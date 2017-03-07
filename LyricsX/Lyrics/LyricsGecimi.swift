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
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (LXLyrics) -> Void) {
        queue.addOperation {
            let lrcDatas = self.searchLrcFor(title: title, artist: artist)
            lrcDatas.forEach() { lrcData in
                var metadata = lrcData
                metadata[.source] = "Gecimi"
                metadata[.searchTitle] = title
                metadata[.searchArtist] = artist
                if let lrc = LXLyrics(metadata: metadata) {
                    completionBlock(lrc)
                }
            }
        }
    }
    
    func cancelFetching() {
        queue.cancelAllOperations()
    }
    
    private func searchLrcFor(title: String, artist: String) -> [[LXLyrics.MetadataKey: String]] {
        let urlStr = "http://gecimi.com/api/lyric/\(title)/\(artist)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["result"].array else {
            return []
        }
        
        return array.flatMap() { item in
            var result: [LXLyrics.MetadataKey: String] = [:]
            result[.lyricsURL] = item["lrc"].string
            
            if let aid = item["aid"].string,
                let url = URL(string:"http://gecimi.com/api/cover/\(aid)"),
                let data = try? Data(contentsOf: url),
                let artworkURL = JSON(data)["result"]["cover"].string {
                    result[.artworkURL] = artworkURL
            }
            return result
        }
    }

}
