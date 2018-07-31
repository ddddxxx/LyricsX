//
//  LyricsMetaData+Extension.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
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
import LyricsProvider

extension Lyrics.MetaData.Key {
    static var localURL = Lyrics.MetaData.Key("localURL")
    static var title = Lyrics.MetaData.Key("title")
    static var artist = Lyrics.MetaData.Key("artist")
    static var needsPersist = Lyrics.MetaData.Key("needsPersist")
}

extension Lyrics.MetaData {
    
    var localURL: URL? {
        get { return data[.localURL] as? URL }
        set { data[.localURL] = newValue }
    }
    
    var title: String? {
        get { return request?.title ?? data[.title] as? String }
        set { data[.title] = newValue }
    }
    
    var artist: String? {
        get { return request?.artist ?? data[.artist] as? String }
        set { data[.artist] = newValue }
    }
    
    var needsPersist: Bool {
        get { return data[.needsPersist] as? Bool ?? false }
        set { data[.needsPersist] = newValue }
    }
}
