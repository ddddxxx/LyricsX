//
//  LyricsXiami.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/5.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation
import SwiftyJSON

class LyricsXiami {
    
    func searchLrcFor(title: String, artist: String, using: @escaping (URL?) -> Swift.Void) {
        self.searchXiamiIDFor(title: title, artist: artist) {
            guard let xiamiID = $0 else {
                using(nil)
                return
            }
            self.searchLrcFor(xiamiID: xiamiID) { using($0) }
        }
    }
    
    private func searchXiamiIDFor(title: String, artist: String, using: @escaping (Int?) -> Swift.Void) {
        let urlStr = "http://www.xiami.com/web/search-songs?key=\(title) \(artist)"
        let convertedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string: convertedURLStr)!
        
        let req = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        req.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: req as URLRequest) { (data, response, error) in
            guard error == nil else {
                print("search xiami ID error: \(error!)")
                using(nil)
                return
            }
            guard data != nil else {
                using(nil)
                return
            }
            
            let json = JSON(data!)
            if let xiamiIDString = json[0]["id"].string, let xiamiID = Int(xiamiIDString) {
                using(xiamiID)
            } else {
                using(nil)
            }
        }
        task.resume()
    }
    
    private func searchLrcFor(xiamiID: Int, using: @escaping (URL?) -> Swift.Void) {
        let urlStr = "http://www.xiami.com/song/playlist/id/\(xiamiID)"
        let url = URL(string: urlStr)!
        
        let req = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        req.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: req as URLRequest) { (data, response, error) in
            guard error == nil else {
                print("search xiami lyrics error: \(error!)")
                using(nil)
                return
            }
            guard data != nil else {
                using(nil)
                return
            }
            
            let parser = LyricsXiamiXMLParser()
            let lrcURL = parser.parseLrcURL(data: data!).flatMap({ URL(string: $0) })
            using(lrcURL)
        }
        task.resume()
    }
    
}

// MARK: - XMLParser

private class LyricsXiamiXMLParser: NSObject, XMLParserDelegate {
    
    var XMLContent = String()
    
    var lrcResult = String()
    
    func parseLrcURL(data: Data) -> String? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        if success {
            return lrcResult
        } else {
            return nil
        }
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "lyric" {
            lrcResult = XMLContent
        } else {
            XMLContent = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
    
}





