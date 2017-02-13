//
//  LyricsSourceHelper.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/11.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

protocol LyricsSource {
    
    func fetchLyrics(title: String, artist: String) -> [LXLyrics]
    
}

class LyricsSourceHelper {
    
    private let lyricsSource: [LyricsSource]
    private let queue: OperationQueue
    
    var lyrics: [LXLyrics]
    
    init() {
        queue = OperationQueue()
        lyricsSource = [
            LyricsXiami(),
            LyricsGecimi(),
            LyricsTTPod()
        ]
        lyrics = []
    }
    
    /// if last request has not completed, last completionBlock will not execute
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping () -> Void) {
        lyrics = []
        cancelFetching()
        
        let fetchOps = lyricsSource.map() { src in
            return BlockOperation() {
                self.lyrics += src.fetchLyrics(title: title, artist: artist)
            }
        }
        
        let completionOp = BlockOperation() {
            // TODO: sort
            completionBlock()
        }
        fetchOps.forEach() { completionOp.addDependency($0) }
        
        queue.addOperations(fetchOps, waitUntilFinished: false)
        queue.addOperation(completionOp)
    }
    
    func cancelFetching() {
        queue.cancelAllOperations()
    }
    
//    func sortLrcs() {
//        lyrics.sort() { lhs, rhs in
//            
//        }
//    }
    
}
