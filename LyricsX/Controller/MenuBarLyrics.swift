//
//  MenuBarLyrics.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

class MenuBarLyrics: NSObject {
    
    static let shared = MenuBarLyrics()
    
    let statusItem: NSStatusItem
    var buttonImage = #imageLiteral(resourceName: "status_bar_icon")
    var buttonlength: CGFloat = 30
    
    private var lyrics = ""
    
    private override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePositionChange), name: .PositionChange, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(updateStatusItem), name: .NSWorkspaceDidActivateApplication, object: nil)
        Preference.subscribe(key: MenuBarLyricsEnabled) { _ in
            self.updateStatusItem()
        }
        updateStatusItem()
    }
    
    func handlePositionChange(_ n: Notification) {
        let lrc = (n.userInfo?["lrc"] as? LyricsLine)?.sentence ?? ""
        if lrc == lyrics {
            return
        }
        
        lyrics = lrc
        updateStatusItem()
    }
    
    func updateStatusItem() {
        guard Preference[MenuBarLyricsEnabled], lyrics != "" else {
            setImageStatusItem()
            return
        }
        
        setTextStatusItem(string: lyrics)
        if statusItem.isVisibe != true {
            setImageStatusItem()
        }
    }
    
    private func setTextStatusItem(string: String) {
        statusItem.button?.title = string
        statusItem.button?.image = nil
        statusItem.length = NSVariableStatusItemLength
    }
    
    private func setImageStatusItem() {
        statusItem.button?.title = ""
        statusItem.button?.image = buttonImage
        statusItem.length = buttonlength
    }
}


// MARK: - Status Item Visibility

extension NSStatusItem {
    
    fileprivate var isVisibe: Bool? {
        guard let windowFrame = button?.frame,
            let frame = button?.window?.convertToScreen(windowFrame) else {
            return nil
        }
        
        let point = CGPoint(x: frame.midX, y: frame.midY)
        let carbonPoint = point.carbonScreenPoint()
        
        guard let element = carbonPoint.getUIElementCopy() else {
            return false
        }
        
        return getpid() == element.pid
    }
}

extension CGPoint {
    
    fileprivate func carbonScreenPoint() -> CGPoint {
        guard let screen = NSScreen.screens()?.first(where: {$0.frame.contains(self)}) else {
            return .zero
        }
        return CGPoint(x: x, y: screen.frame.height - y - 1)
    }
    
    fileprivate func getUIElementCopy() -> AXUIElement? {
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(x), Float(y), &element)
        guard error == .success else {
            return nil
        }
        return element
    }
}

extension AXUIElement {
    
    fileprivate var pid: pid_t? {
        var pid: pid_t = 0
        let error = AXUIElementGetPid(self, &pid)
        guard error == .success else {
            return nil
        }
        return pid
    }
}
