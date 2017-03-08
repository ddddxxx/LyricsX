//
//  Lyrics163.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class Lyrics163: LyricsSource {
    
    private let queue: OperationQueue
    private let session: URLSession
    
    init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
    }
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (LXLyrics) -> Void) {
        let url = URL(string: "http://music.163.com/api/search/pc")!
        let body = "s=\(title) \(artist)&offset=0&limit=10&type=1".data(using: .utf8)!
        
        var req = URLRequest(url: url)
        req.allHTTPHeaderFields = [
            "Cookie": "appver=1.5.0.75771;",
            "Referer": "http://music.163.com/",
        ]
        req.httpMethod = "POST"
        req.httpBody = body
        
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let array = JSON(data: data)["result"]["songs"].array else {
                return
            }
            
            for item in array {
                self.queue.addOperation {
                    guard let id = item["id"].number?.intValue,
                        var lyrics = self.lyricsFor(id: id) else {
                            return
                    }
                    var metadata: [LXLyrics.MetadataKey: String] = [
                        .searchTitle: title,
                        .searchArtist: artist,
                        .source: "163",
                    ]
                    metadata[.artworkURL] = item["album"]["picUrl"].string
                    
                    lyrics.idTags[.title] = item["name"].string
                    lyrics.idTags[.artist] = item["artists"][0]["name"].string
                    lyrics.idTags[.album] = item["album"]["name"].string
                    lyrics.idTags[.lrcBy] = "163"
                    
                    lyrics.metadata = metadata
                    completionBlock(lyrics)
                }
            }
        }
        task.resume()
    }
    
    func cancelFetching() {
        queue.cancelAllOperations()
    }
    
    private func lyricsFor(id: Int) -> LXLyrics? {
        let url = URL(string: "http://music.163.com/api/song/lyric?id=\(id)&lv=1&kv=1&tv=-1")!
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let json = JSON(data: data)
        guard let lrcContent = json["lrc"]["lyric"].string else {
            return nil
        }
        
        // TODO: translated lyrics
        // let transLrc = json["tlyric"]["lyric"]
        
        return LXLyrics(lrcContent)
    }
    
}
