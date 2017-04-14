//
//  LyricsGecimi.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let Gecimi = Lyrics.MetaData.Source("Gecimi")
}

class LyricsGecimi: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void) {
        guard case let .info(title, artist) = criteria else {
            // cannot search by keyword
            return
        }
        
        queue.addOperation {
            let lrcDatas = self.searchLrcFor(title: title, artist: artist)
            for (index, lrcData) in lrcDatas.enumerated() {
                self.queue.addOperation {
                    guard var lrc = Lyrics(url: lrcData.lyricsURL) else {
                        return
                    }
                    
                    lrc.metadata.source = .Gecimi
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    lrc.metadata.artworkURL = lrcData.artworkURL
                    
                    completionBlock(lrc)
                }
            }
        }
    }
    
    private func searchLrcFor(title: String, artist: String) -> [(lyricsURL: URL, artworkURL: URL?)] {
        let urlStr = "http://gecimi.com/api/lyric/\(title)/\(artist)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["result"].array else {
            return []
        }
        
        return array.flatMap() { item in
            guard let lrcURL = item["lrc"].url else {
                return nil
            }
            
            if let aid = item["aid"].string,
                let url = URL(string:"http://gecimi.com/api/cover/\(aid)"),
                let data = try? Data(contentsOf: url),
                let artworkURL = JSON(data)["result"]["cover"].url {
                    return (lrcURL, artworkURL)
            }
            return (lrcURL, nil)
        }
    }
}
