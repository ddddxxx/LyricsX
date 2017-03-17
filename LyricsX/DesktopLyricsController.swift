//
//  DesktopLyricsController.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/2/4.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SnapKit
import EasyPreference

class DesktopLyricsWindowController: NSWindowController {
    
    override func windowDidLoad() {
        let visibleFrame = NSScreen.main()!.visibleFrame
        window?.setFrame(visibleFrame, display: true)
        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.ignoresMouseEvents = true
        window?.level = Int(CGWindowLevelForKey(.floatingWindow))
    }
    
}

class DesktopLyricsViewController: NSViewController {
    
    @IBOutlet weak var backgroundView: NSBox!
    @IBOutlet weak var firstLineLrcView: NSTextField!
    @IBOutlet weak var secondLineLrcView: NSTextField!
    @IBOutlet weak var waitingLrcView: NSTextField!
    
    var enabled = Preference[DesktopLyricsEnabled] {
        didSet {
            backgroundView.isHidden = !enabled
        }
    }
    
    var onAnimation = false {
        didSet {
            view.needsUpdateConstraints = true
            view.needsLayout = true
            view.layoutSubtreeIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shadowColor = Preference.object(for: DesktopLyricsShadowColor)!
        updateShadow(color: shadowColor)
        
        makeConstraints()
        
        NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            var lrc = n.userInfo?["lrc"] as? String ?? ""
            var next = n.userInfo?["next"] as? String ?? ""
            if lrc.replacingOccurrences(of: " ", with: "") == "" {
                lrc = ""
            }
            if next.replacingOccurrences(of: " ", with: "") == "" {
                next = ""
            }
            
            self.displayLrc(lrc, secondLine: next)
        }
        
        Preference.subscribe(key: DesktopLyricsEnabled) { change in
            self.enabled = change.newValue
        }
        
        Preference.subscribe(key: DesktopLyricsHeighFromDock) { change in
            self.lyricsHeightConstraint?.update(offset: -change.newValue)
        }
        
        Preference.subscribe(key: DesktopLyricsFontSize) { change in
            self.updateFontSize(change.newValue)
        }
        
        Preference.subscribe(key: DesktopLyricsBackgroundColor) { change in
            self.backgroundView.fillColor = change.newValue
        }
        
        Preference.subscribe(key: DesktopLyricsShadowColor) { change in
            self.updateShadow(color: change.newValue)
        }
    }
    
    func updateShadow(color: NSColor) {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowColor = color
        shadow.shadowOffset = .zero
        self.firstLineLrcView.shadow = shadow
        self.secondLineLrcView.shadow = shadow
        self.waitingLrcView.shadow = shadow
    }
    
    func updateFontSize(_ size: Int) {
        let insetX = size
        let insetY = size / 3
        let leading = size * 3 / 2
        topInsetConstraint.forEach() { $0.update(offset: insetY) }
        bottomInsetConstraint.forEach() { $0.update(offset: -insetY) }
        leftInsetConstraint.forEach() { $0.update(offset: insetX) }
        rightInsetConstraint.forEach() { $0.update(offset: -insetX) }
        leadingConstraint.forEach() { $0.update(offset: -leading) }
        
        backgroundView.cornerRadius = CGFloat(size) / 2
        view.needsLayout = true
        view.layoutSubtreeIfNeeded()
    }
    
    func displayLrc(_ firstLine: String, secondLine: String) {
        guard enabled else {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.secondLineLrcView.stringValue = firstLine
            self.waitingLrcView.stringValue = secondLine
            self.onAnimation = true
        }, completionHandler: {
            self.firstLineLrcView.stringValue = firstLine
            self.secondLineLrcView.stringValue = secondLine
            self.onAnimation = false
        })
    }
    
    // MARK: Layout
    
    var normalConstraint: [SnapKit.Constraint] = []
    var animatedConstraint: [SnapKit.Constraint] = []
    
    var firstLineConstraint: [SnapKit.Constraint] = []
    var secondLineConstraint: [SnapKit.Constraint] = []
    var waitingLineConstraint: [SnapKit.Constraint] = []
    
    var lyricsHeightConstraint: SnapKit.Constraint?
    
    var topInsetConstraint: [SnapKit.Constraint] = []
    var bottomInsetConstraint: [SnapKit.Constraint] = []
    var leftInsetConstraint: [SnapKit.Constraint] = []
    var rightInsetConstraint: [SnapKit.Constraint] = []
    
    var leadingConstraint: [SnapKit.Constraint] = []
    
    func makeConstraints() {
        let fontSize = Preference[DesktopLyricsFontSize]
        let insetX = fontSize
        let insetY = fontSize / 3
        let leading = fontSize * 3 / 2
        
        firstLineLrcView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            
            leadingConstraint += [make.lastBaseline.equalTo(secondLineLrcView).offset(-leading).constraint]
            
            let cons1 = make.left.greaterThanOrEqualToSuperview().offset(insetX).constraint
            let cons2 = make.right.lessThanOrEqualToSuperview().offset(-insetX).constraint
            
            let cons3 = make.top.equalToSuperview().offset(insetY).priority(750).constraint
            let cons4 = make.bottom.equalToSuperview().offset(-insetY).priority(500).constraint
            normalConstraint += [cons1, cons2, cons3, cons4]
            
            firstLineConstraint += [cons3]
            
            topInsetConstraint += [cons3]
            bottomInsetConstraint += [cons4]
            leftInsetConstraint += [cons1]
            rightInsetConstraint += [cons2]
        }
        
        secondLineLrcView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            leftInsetConstraint += [make.left.greaterThanOrEqualToSuperview().offset(insetX).constraint]
            rightInsetConstraint += [make.right.lessThanOrEqualToSuperview().offset(-insetX).constraint]
            
            leadingConstraint += [make.lastBaseline.equalTo(waitingLrcView).offset(-leading).constraint]
            
            let cons1 = make.top.equalToSuperview().offset(insetY).priority(500).constraint
            let cons2 = make.bottom.equalToSuperview().offset(-insetY).priority(750).constraint
            normalConstraint += [cons1, cons2]
            
            let cons3 = make.top.equalToSuperview().offset(insetY).priority(750).constraint
            let cons4 = make.bottom.equalToSuperview().offset(-insetY).priority(500).constraint
            animatedConstraint += [cons3, cons4]
            
            secondLineConstraint += [cons2, cons3]
            
            topInsetConstraint += [cons1, cons3]
            bottomInsetConstraint += [cons2, cons4]
        }
        
        waitingLrcView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            
            let cons1 = make.left.greaterThanOrEqualToSuperview().offset(insetX).constraint
            let cons2 = make.right.lessThanOrEqualToSuperview().offset(-insetX).constraint
            
            let cons3 = make.top.equalToSuperview().offset(insetY).priority(500).constraint
            let cons4 = make.bottom.equalToSuperview().offset(-insetY).priority(750).constraint
            animatedConstraint += [cons1, cons2, cons3, cons4]
            
            waitingLineConstraint += [cons4]
            
            topInsetConstraint += [cons3]
            bottomInsetConstraint += [cons4]
            leftInsetConstraint += [cons1]
            rightInsetConstraint += [cons2]
        }
        
        let heightFromDock = Preference[DesktopLyricsHeighFromDock]
        backgroundView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            lyricsHeightConstraint = make.bottom.equalToSuperview().offset(-heightFromDock).constraint
        }
        
        onAnimation = false
        view.needsUpdateConstraints = true
        view.updateConstraintsForSubtreeIfNeeded()
        view.layoutSubtreeIfNeeded()
    }
    
    override func updateViewConstraints() {
        if onAnimation {
            normalConstraint.forEach() { $0.deactivate() }
            animatedConstraint.forEach() { $0.activate() }
        } else {
            normalConstraint.forEach() { $0.activate() }
            animatedConstraint.forEach() { $0.deactivate() }
        }
        super.updateViewConstraints()
    }
    
    override func viewWillLayout() {
        guard enabled else {
            backgroundView.isHidden = true
            return
        }
        backgroundView.isHidden = false
        
        if onAnimation {
            firstLineLrcView.alphaValue = 0
            waitingLrcView.alphaValue = 1
            
            guard secondLineLrcView.stringValue != "" else {
                secondLineLrcView.isHidden = true
                secondLineConstraint.forEach() { $0.deactivate() }
                backgroundView.alphaValue = 0
                return
            }
            secondLineLrcView.isHidden = false
            backgroundView.alphaValue = 1
            
            guard waitingLrcView.stringValue != "" else {
                waitingLrcView.isHidden = true
                waitingLineConstraint.forEach() { $0.deactivate() }
                return
            }
            waitingLrcView.isHidden = false
        } else {
            firstLineLrcView.alphaValue = 1
            waitingLrcView.alphaValue = 0
            
            guard firstLineLrcView.stringValue != "" else {
                firstLineLrcView.isHidden = true
                firstLineConstraint.forEach() { $0.deactivate() }
                backgroundView.alphaValue = 0
                return
            }
            firstLineLrcView.isHidden = false
            backgroundView.alphaValue = 1
            
            guard secondLineLrcView.stringValue != "" else {
                secondLineLrcView.isHidden = true
                secondLineConstraint.forEach() { $0.deactivate() }
                return
            }
            secondLineLrcView.isHidden = false
        }
        super.viewWillLayout()
    }
    
}
