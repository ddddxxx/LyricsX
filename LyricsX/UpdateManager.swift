//
//  UpdateManager.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/5/2.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SwiftyJSON

class UpdateManager: NSObject, NSUserNotificationCenterDelegate {
    
    static let shared = UpdateManager()
    
    private override init() {}
    
    static var remoteVersion: Semver? {
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
        return Semver(tag)
    }
    
    static var localVersion: Semver {
        let info = Bundle.main.infoDictionary!
        let shortVersion = info["CFBundleShortVersionString"] as! String
        return Semver(shortVersion)!
    }
    
    func checkForUpdate() {
        let localVersion = UpdateManager.localVersion
        guard let remoteVersion = UpdateManager.remoteVersion,
            remoteVersion > localVersion else {
            return
        }
        
        if let skipVersionString = Preference[.NotifiedUpdateVersion],
            let skipVersion = Semver(skipVersionString),
            skipVersion == remoteVersion {
            return
        } else {
            Preference[.NotifiedUpdateVersion] = remoteVersion.description
        }
        
        let noti = NSUserNotification()
        noti.title = "A new version of LyricsX is available!"
        noti.informativeText = "LyricsX \(remoteVersion) is now available -- you have \(localVersion). Would you like to download it now?"
        
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(noti)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        center.removeAllDeliveredNotifications()
        let url = URL(string: "https://github.com/XQS6LB3A/LyricsX/releases/latest")!
        NSWorkspace.shared().open(url)
    }
    
}

struct Semver {
    
    var major: Int
    var minor: Int
    var patch: Int
    
    init?(_ string:String) {
        let components = string.components(separatedBy: ".").flatMap { Int($0) }
        guard components.count == 3 else {
            return nil
        }
        major = components[0]
        minor = components[1]
        patch = components[2]
    }
}

extension Semver: Comparable {
    
    public static func ==(lhs: Semver, rhs: Semver) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
    
    public static func <(lhs: Semver, rhs: Semver) -> Bool {
        return (lhs.major < rhs.major) ||
            (lhs.major == rhs.major && lhs.minor < rhs.minor) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
    
    public static func <=(lhs: Semver, rhs: Semver) -> Bool {
        return !(lhs > rhs)
    }
    
    public static func >=(lhs: Semver, rhs: Semver) -> Bool {
        return !(lhs < rhs)
    }
    
    public static func >(lhs: Semver, rhs: Semver) -> Bool {
        return (lhs.major > rhs.major) ||
            (lhs.major == rhs.major && lhs.minor > rhs.minor) ||
            (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch > rhs.patch)
    }
}

extension Semver: CustomStringConvertible {
    
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
