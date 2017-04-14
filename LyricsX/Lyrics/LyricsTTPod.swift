//
//  LyricsTTPod.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let TTPod = Lyrics.MetaData.Source("TTPod")
}

class LyricsTTPod: LyricsSource {
    
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
            let urlStr = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=\(artist)&title=\(title)"
            let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: convertedURLStr)!
            
            guard let data = try? Data(contentsOf: url),
                let lrcContent = JSON(data)["data"]["lrc"].string,
                var lrc = Lyrics(lrcContent)else {
                    return
            }
            
            lrc.metadata.source = .TTPod
            lrc.metadata.searchBy = criteria
            lrc.metadata.searchIndex = 0
            
            completionBlock(lrc)
        }
    }
}
