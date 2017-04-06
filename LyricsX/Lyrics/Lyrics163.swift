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
    
    let queue: OperationQueue
    private let session: URLSession
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: queue)
    }
    
    func iFeelLucky(title: String, artist: String, completionBlock: @escaping (Lyrics) -> Void) {
        let url = URL(string: "http://music.163.com/api/search/pc")!
        let body = "s=\(title) \(artist)&offset=0&limit=1&type=1".data(using: .utf8)!
        
        var req = URLRequest(url: url)
        req.allHTTPHeaderFields = [
            "Cookie": "appver=1.5.0.75771;",
            "Referer": "http://music.163.com/",
        ]
        req.httpMethod = "POST"
        req.httpBody = body
        
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data else {
                    return
            }
            let item = JSON(data: data)["result"]["songs"][0]
            guard let id = item["id"].number?.intValue,
                var lyrics = self.lyricsFor(id: id) else {
                    return
            }
            var metadata: [Lyrics.MetadataKey: Any] = [
                .searchTitle: title,
                .searchArtist: artist,
                .source: "163",
                ]
            metadata[.artworkURL] = item["album"]["picUrl"].url
            
            lyrics.idTags[.title] = item["name"].string
            lyrics.idTags[.artist] = item["artists"][0]["name"].string
            lyrics.idTags[.album] = item["album"]["name"].string
            lyrics.idTags[.lrcBy] = "163"
            
            lyrics.metadata = metadata
            completionBlock(lyrics)
        }
        task.resume()
    }
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (Lyrics) -> Void) {
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
            
            for (index, item) in array.enumerated() {
                self.queue.addOperation {
                    guard let id = item["id"].number?.intValue,
                        var lyrics = self.lyricsFor(id: id) else {
                            return
                    }
                    var metadata: [Lyrics.MetadataKey: Any] = [
                        .searchTitle:   title,
                        .searchArtist:  artist,
                        .searchIndex:   index,
                        .source:        "163",
                    ]
                    metadata[.artworkURL] = item["album"]["picUrl"].url
                    
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
    
    private func lyricsFor(id: Int) -> Lyrics? {
        let url = URL(string: "http://music.163.com/api/song/lyric?id=\(id)&lv=1&kv=1&tv=-1")!
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let json = JSON(data: data)
        guard let lrcContent = json["lrc"]["lyric"].string,
            var lrc = Lyrics(lrcContent) else {
            return nil
        }
        
        if let transLrcContent = json["tlyric"]["lyric"].string,
            let transLrc = Lyrics(transLrcContent) {
            lrc.merge(translation: transLrc)
            lrc.metadata[.includeTranslation] = true
        }
        
        return lrc
    }
    
}

extension Lyrics {
    
    mutating func merge(translation: Lyrics) {
        var index = lyrics.startIndex
        var transIndex = translation.lyrics.startIndex
        while index < lyrics.endIndex, transIndex < translation.lyrics.endIndex {
            if lyrics[index].position == translation.lyrics[transIndex].position {
                let transStr = translation.lyrics[transIndex].sentence
                if transStr.characters.count > 0 {
                    lyrics[index].translation = transStr
                }
                lyrics.formIndex(after: &index)
                translation.lyrics.formIndex(after: &transIndex)
            } else if lyrics[index].position > translation.lyrics[transIndex].position {
                translation.lyrics.formIndex(after: &transIndex)
            } else {
                lyrics.formIndex(after: &index)
            }
        }
    }
    
}
