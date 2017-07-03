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

public final class LyricsXiami: LyricsSource {
    
    let session = { () -> URLSession in
        let config = URLSessionConfiguration.default.with {
            $0.timeoutIntervalForRequest = 10
        }
        return URLSession(configuration: config)
    }()
    let dispatchGroup = DispatchGroup()
    
    public func cancelSearch() {
        session.getTasksWithCompletionHandler() { dataTasks, _, _ in
            dataTasks.forEach {
                $0.cancel()
            }
        }
    }
    
    public func searchLyrics(criteria: Lyrics.MetaData.SearchCriteria, duration: TimeInterval, using: @escaping (Lyrics) -> Void, completionHandler: @escaping () -> Void) {
        let keyword = criteria.description
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .uriComponentAllowed)!
        let url = URL(string: "http://www.xiami.com/web/search-songs?key=\(encodedKeyword)")!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data else {
                return
            }
            
            let ids = JSON(data: data).array?.flatMap {
                $0["id"].string.flatMap { Int($0) }
            }
            ids?.enumerated().forEach { index, id in
                self.fetchLyrics(id: id) { lrc in
                    lrc.metadata.source = .Xiami
                    lrc.metadata.searchBy = criteria
                    lrc.metadata.searchIndex = index
                    
                    using(lrc)
                }
            }
        }
        task.resume()
        dispatchGroup.notify(queue: .global(), execute: completionHandler)
    }
    
    private func fetchLyrics(id: Int, completionBlock: @escaping (Lyrics) -> Void) {
        let url = URL(string: "http://www.xiami.com/song/playlist/id/\(id)")!
        let req = URLRequest(url: url)
        dispatchGroup.enter()
        let task = session.dataTask(with: req) { data, resp, error in
            defer {
                self.dispatchGroup.leave()
            }
            guard let data = data,
                let parseResult = LyricsXiamiXMLParser().parseLrcURL(data: data),
                let lrc = Lyrics(url: parseResult.lyricsURL) else {
                return
            }
            lrc.metadata.artworkURL = parseResult.artworkURL
            completionBlock(lrc)
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
