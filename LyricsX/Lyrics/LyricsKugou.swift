//
//  LyricsKugou.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let Kugou = Lyrics.MetaData.Source("Kugou")
}

class LyricsKugou: LyricsSource {
    
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
        
        let mDuration = Int(duration * 1000)
        queue.addOperation {
            let searchItems = self.searchKugouIDFor(keyword: encodedKeyword, duration: mDuration)
            for (index, searchItem) in searchItems.enumerated() {
                self.queue.addOperation {
                    guard var lrc = self.lyricsFor(searchItem) else {
                        return
                    }
                    
                    lrc.metadata.source = .Kugou
                    lrc.metadata.searchIndex = index
                    lrc.metadata.searchBy = criteria
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchKugouIDFor(keyword: String, duration: Int) -> [JSON] {
        let urlStr = "http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=\(keyword)&duration=\(duration)"
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
