//
//  LyricsXiami.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import SwiftyJSON

extension Lyrics.MetaData.Source {
    static let Xiami = Lyrics.MetaData.Source("Xiami")
}

public final class LyricsXiami: CommonLyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    func searchLyricsToken(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, completionHandler: @escaping ([Int]) -> Void) {
        let keyword = criteria.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let url = URL(string: "http://www.xiami.com/web/search-songs?key=\(encodedKeyword)")!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            let ids = data.map(JSON.init)?.array?.flatMap {
                $0["id"].string.flatMap { Int($0) }
            } ?? []
            completionHandler(ids)
        }
        task.resume()
    }
    
    func getLyricsWithToken(token: Int, completionHandler: @escaping (Lyrics?) -> Void) {
        let url = URL(string: "http://www.xiami.com/song/playlist/id/\(token)")!
        let req = URLRequest(url: url)
        let task = session.dataTask(with: req) { data, resp, error in
            guard let data = data,
                let parseResult = LyricsXiamiXMLParser().parseLrcURL(data: data),
                let lrc = Lyrics(url: parseResult.lyricsURL) else {
                completionHandler(nil)
                return
            }
            lrc.metadata.source = .Xiami
            lrc.metadata.artworkURL = parseResult.artworkURL
            completionHandler(lrc)
        }
        task.resume()
    }
}

// MARK: - XMLParser

private class LyricsXiamiXMLParser: NSObject, XMLParserDelegate {
    
    var XMLContent: String?
    
    var lyricsURL: URL?
    var artworkURL: URL?
    
    func parseLrcURL(data: Data) -> (lyricsURL: URL, artworkURL: URL?)? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        guard let lyricsURL = lyricsURL else {
            return nil
        }
        
        return (lyricsURL, artworkURL)
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "lyric":
            lyricsURL = XMLContent.flatMap { URL(string: $0) }
        case "pic":
            artworkURL = XMLContent.flatMap { URL(string: $0) }
        default:
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        XMLContent = string
    }
}
