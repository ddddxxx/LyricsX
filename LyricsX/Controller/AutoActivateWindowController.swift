//
//  AutoActivateWindowController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/22.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class AutoActivateWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
