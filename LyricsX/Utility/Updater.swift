//
//  Updater.swift
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

import Cocoa
import SwiftyJSON
import Semver

var remoteVersion: Semver? {
    let gitHubPath = "XQS6LB3A/LyricsX"
    let url = URL(string: "https://api.github.com/repos/\(gitHubPath)/releases/latest")!
    guard let data = try? Data(contentsOf: url) else { return nil }
    let json = JSON(data: data)
    guard var tag = json["tag_name"].string,
        json["draft"].bool != true,
        json["prerelease"].bool != true else {
            return nil
    }
    if tag[tag.startIndex] == "v" {
        tag.remove(at: tag.startIndex)
    }
    return try? Semver(tag)
}

var localVersion: Semver {
    let info = Bundle.main.infoDictionary!
    let shortVersion = info["CFBundleShortVersionString"] as! String
    return try! Semver(shortVersion)
}

func checkForUpdate(force: Bool = false) {
    let local = localVersion
    guard let remote = remoteVersion else {
        return
    }
    
    guard remote > local else {
        if force {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "You're up-to-date!"
                alert.informativeText = "LyricsX \(local) is currently the newest version available."
                NSApp.activate(ignoringOtherApps: true)
                alert.runModal()
            }
        }
        return
    }
    
    if !force,
        let skipVersionString = defaults[.NotifiedUpdateVersion],
        let skipVersion = try? Semver(skipVersionString),
        skipVersion >= remote {
        return
    }
    
    defaults[.NotifiedUpdateVersion] = remote.description
    
    DispatchQueue.main.async {
        let alert = NSAlert().then {
            $0.messageText = "A new version of LyricsX is available!"
            $0.informativeText = "LyricsX \(remote) is now available -- you have \(localVersion). Would you like to download it now?"
            $0.addButton(withTitle: "Download")
            $0.addButton(withTitle: "Skip")
        }
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            let url = URL(string: "https://github.com/XQS6LB3A/LyricsX/releases")!
            NSWorkspace.shared().open(url)
        }
    }
}
