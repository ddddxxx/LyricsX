//
//  AboutViewController.swift
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

import Cocoa
import Crashlytics

class AboutViewController: NSViewController {
    
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    @IBOutlet var creditsTextView: NSTextView!
    @IBOutlet weak var copyright: NSTextField!
    
    override func viewDidLoad() {
        // swiftlint:disable force_cast
        let info = Bundle.main.infoDictionary!
        let shortVersion = info["CFBundleShortVersionString"] as! String
        let version = info["CFBundleVersion"] as! String
        appName.stringValue = info["CFBundleName"] as! String
        appVersion.stringValue = "Version \(shortVersion)(\(version))"
        copyright.stringValue = info["NSHumanReadableCopyright"] as! String
        // swiftlint:enable force_cast
        
        let creditsURL = Bundle.main.url(forResource: "Credits", withExtension: "rtf")!
        if let credits = try? NSAttributedString(url: creditsURL, options: [:], documentAttributes: nil) {
            creditsTextView.textStorage?.setAttributedString(credits)
        }
        Answers.logCustomEvent(withName: "View About Page")
    }
    
}
