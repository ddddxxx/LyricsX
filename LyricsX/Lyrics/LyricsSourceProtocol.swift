//
//  LyricsSourceProtocol.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/13.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

protocol LyricsConsuming: class {
    
    func lyricsReceived(lyrics: Lyrics)
    
    func fetchCompleted(result: [Lyrics])
}

protocol LyricsSource {
    
    var queue: OperationQueue { get }
    
    init(queue: OperationQueue);
    
    func fetchLyrics(by criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionBlock: @escaping (Lyrics) -> Void)
}
