//
//  AboutViewController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/21.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appVersion: NSTextField!
    
    override func viewDidLoad() {
        let info = Bundle.main.infoDictionary!
        appName.stringValue = info["CFBundleName"] as! String
        let shortVersion = info["CFBundleShortVersionString"] as! String
        let version = info["CFBundleVersion"] as! String
        appVersion.stringValue = "\(shortVersion)(\(version))"
    }
    
}
