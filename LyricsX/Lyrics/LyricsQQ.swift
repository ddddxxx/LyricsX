//
//  LyricsQQ.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/21.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsQQ: LyricsSource {
    
    let queue: OperationQueue
    
    required init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
    }
    
    func fetchLyrics(title: String, artist: String, completionBlock: @escaping (LXLyrics) -> Void) {
        let urlString: String = "http://s.music.qq.com/fcgi-bin/music_search_new_platform?t=0&n=10&aggr=1&cr=1&loginUin=0&format=json&inCharset=GB2312&outCharset=utf-8&notice=0&platform=jqminiframe.json&needNewCode=0&p=1&catZhida=0&remoteplace=sizer.newclient.next_song&w=\(title) \(artist)"
        let convertedURLStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        guard let data = try? Data(contentsOf: url), let array = JSON(data)["data"]["song"]["list"].array else {
            return
        }
        
        for item in array {
            queue.addOperation {
                guard let f = item["f"].string,
                    let range = f.range(of: "|"),
                    let id = Int(f.substring(to: range.lowerBound)),
                    var lrc = self.lyricsFor(id: id) else {
                    return
                }
                
                var metadata: [LXLyrics.MetadataKey: String] = [:]
                metadata[.source] = "QQMusic"
                metadata[.searchTitle] = title
                metadata[.searchArtist] = artist
                metadata[.artworkURL] = "http://imgcache.qq.com/music/photo/album/\(id%100)/\(id).jpg"
                
                lrc.metadata = metadata
                
                completionBlock(lrc)
            }
        }
    }
    
    private func lyricsFor(id: Int) -> LXLyrics? {
        let url = URL(string: "http://music.qq.com/miniportal/static/lyric/\(id%100)/\(id).xml")!
        let parser = LyricsQQXMLParser()
        guard let lrcData = try? Data(contentsOf: url),
            let lrcContent = parser.parseLrcContents(data: lrcData) else {
            return nil
        }
        return LXLyrics(lrcContent)
    }
    
}

private class LyricsQQXMLParser: NSObject, XMLParserDelegate {
    
    var lrcContents: String?
    
    override init() {
        super.init()
    }
    
    func parseLrcContents(data:Data) -> String? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success: Bool = parser.parse()
        if !success {
            return nil
        }
        return lrcContents
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        lrcContents = String(data: CDATABlock, encoding: .utf8)
    }
    
}
