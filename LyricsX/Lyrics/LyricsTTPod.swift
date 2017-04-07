//
//  LyricsTTPod.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsTTPod: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (Lyrics) -> Void) {
        queue.addOperation {
            let urlStr = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=\(artist)&title=\(title)"
            let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: convertedURLStr)!
            
            guard let data = try? Data(contentsOf: url),
                let lrcContent = JSON(data)["data"]["lrc"].string,
                var lrc = Lyrics(lrcContent)else {
                    return
            }
            
            var metadata: [Lyrics.MetadataKey: Any] = [:]
            metadata[.source]       = "TTPod"
            metadata[.searchTitle]  = title
            metadata[.searchArtist] = artist
            metadata[.searchIndex]  = 0
            
            lrc.metadata = metadata
            
            completionBlock(lrc)
        }
    }
    
}
