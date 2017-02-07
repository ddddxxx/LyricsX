//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

// Notification
let LyricsLoadedNotification = "LyricsLoaded"
let LyricsShouldDisplayNotification = "LyricsShouldDisplay"

extension Notification.Name {
    static var lyricsLoaded = Notification.Name(LyricsLoadedNotification)
    static var lyricsShouldDisplay = Notification.Name(LyricsShouldDisplayNotification)
}
