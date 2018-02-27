//
//  LyricsMetaData+Extension.swift
//  LyricsX
//
//  Created by 邓翔 on 2018/1/27.
//  Copyright © 2018年 ddddxxx. All rights reserved.
//

import Foundation
import LyricsProvider

extension Lyrics.MetaData.Key {
    static var localURL = Lyrics.MetaData.Key("localURL")
    static var title    = Lyrics.MetaData.Key("title")
    static var artist   = Lyrics.MetaData.Key("artist")
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
}
