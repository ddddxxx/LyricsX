//
//  AboutViewController.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Cocoa
import Crashlytics

class AboutViewController: NSViewController {
    
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    // NSTextView doesn't support weak references
    @IBOutlet var creditsTextView: NSTextView!
    @IBOutlet weak var copyright: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swiftlint:disable force_cast
        let info = Bundle.main.infoDictionary!
        let shortVersion = info["CFBundleShortVersionString"] as! String
        let version = info["CFBundleVersion"] as! String
        #if IS_FOR_MAS
            let channel = "App Store"
        #else
            let channel = "GitHub"
        #endif
        appName.stringValue = info["CFBundleName"] as! String
        appVersion.stringValue = "\(channel) Version \(shortVersion)(\(version))"
        copyright.stringValue = info["NSHumanReadableCopyright"] as! String
        // swiftlint:enable force_cast
        
        let creditsURL = Bundle.main.url(forResource: "Credits", withExtension: "rtf")!
        if let credits = try? NSMutableAttributedString(url: creditsURL, options: [:], documentAttributes: nil) {
            credits.addAttribute(.foregroundColor, value: NSColor.labelColor, range: credits.fullRange)
            creditsTextView.textStorage?.setAttributedString(credits)
        }
        Answers.logCustomEvent(withName: "View About Page")
    }
    
}
