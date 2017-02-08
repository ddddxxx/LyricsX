//
//  GlobalConst.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/7.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Foundation

// MARK: - Notification Name

let LyricsShouldDisplayNotification = "LyricsShouldDisplay"

extension Notification.Name {
    static var lyricsShouldDisplay = Notification.Name(LyricsShouldDisplayNotification)
}

// MARK: - User Defaults

// Menu
let DesktopLyricsEnabled = "DesktopLyricsEnabled"
let MenuBarLyricsEnabled = "MenuBarLyricsEnabled"
