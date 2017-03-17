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

class DesktopLyricsController: NSWindowController {
    
    var backgroundView: NSView!
    var firstLineLrcView: NSTextField!
    var secondLineLrcView: NSTextField!
    var waitingLrcView: NSTextField!
    var reversed = false
    
    var enabled: Bool! {
        didSet {
            backgroundView.isHidden = !enabled
        }
    }
    
    var fontName: String!
    var fontSize: Int!
    
    var observerTokens = [NSObjectProtocol]()
    
    init() {
        let visibleFrame = NSScreen.main()!.visibleFrame
        let window = NSWindow(contentRect: visibleFrame, styleMask: [.borderless, .fullSizeContentView, .texturedBackground], backing: .buffered, defer: false)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = Int(CGWindowLevelForKey(.floatingWindow))
        window.collectionBehavior = .canJoinAllSpaces
        window.contentView?.wantsLayer=true
        super.init(window: window)
        
        enabled = Preference[DesktopLyricsEnabled]
        fontName = Preference[DesktopLyricsFontName]!
        fontSize = Preference[DesktopLyricsFontSize]
        let backgroundColor = Preference.object(for: DesktopLyricsBackgroundColor)
        let lyricsColor = Preference.object(for: DesktopLyricsColor)
        let shadowColor = Preference.object(for: DesktopLyricsShadowColor)
        
        let font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        backgroundView = NSView()
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = backgroundColor?.cgColor
        backgroundView.layer?.cornerRadius = CGFloat(fontSize / 2)
        backgroundView.isHidden = !enabled
        window.contentView?.addSubview(backgroundView)
        
        firstLineLrcView = NSTextField(labelWithString: "")
        firstLineLrcView.textColor = lyricsColor
        firstLineLrcView.font = font
        firstLineLrcView.alignment = .center
        backgroundView.addSubview(firstLineLrcView)
        
        secondLineLrcView = NSTextField(labelWithString: "")
        secondLineLrcView.textColor = lyricsColor
        secondLineLrcView.font = font
        secondLineLrcView.alignment = .center
        backgroundView.addSubview(secondLineLrcView)
        
        waitingLrcView = NSTextField(labelWithString: "")
        waitingLrcView.textColor = lyricsColor
        waitingLrcView.font = font
        waitingLrcView.alignment = .center
        backgroundView.addSubview(waitingLrcView)
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowColor = shadowColor
        shadow.shadowOffset = .zero
        firstLineLrcView.shadow = shadow
        secondLineLrcView.shadow = shadow
        waitingLrcView.shadow = shadow
        
        makeConstraints()
        
        displayLrc("LyricsX", secondLine: "")
        
        observerTokens += [NotificationCenter.default.addObserver(forName: .lyricsShouldDisplay, object: nil, queue: .main) { n in
            var lrc = n.userInfo?["lrc"] as? String ?? ""
            var next = n.userInfo?["next"] as? String ?? ""
            if lrc.replacingOccurrences(of: " ", with: "") == "" {
                lrc = ""
            }
            if next.replacingOccurrences(of: " ", with: "") == "" {
                next = ""
            }
            
            self.displayLrc(lrc, secondLine: next)
        }]
        
        Preference.subscribe(key: DesktopLyricsEnabled) { change in
            self.enabled = change.newValue
        }
        
        Preference.subscribe(key: DesktopLyricsHeighFromDock) { change in
            self.lyricsHeightConstraint?.update(offset: -change.newValue)
        }
        
        Preference.subscribe(key: DesktopLyricsFontSize) { change in
            self.fontSize = change.newValue
            self.updateFontSize()
        }
        
        Preference.subscribe(key: DesktopLyricsFontName) { change in
            self.fontName = change.newValue
            self.updateFontName()
        }
        
        Preference.subscribe(key: DesktopLyricsBackgroundColor) { change in
            self.backgroundView.layer?.backgroundColor = change.newValue.cgColor
        }
        
        Preference.subscribe(key: DesktopLyricsColor) { change in
            self.firstLineLrcView.textColor = change.newValue
            self.secondLineLrcView.textColor = change.newValue
            self.waitingLrcView.textColor = change.newValue
        }
        
        Preference.subscribe(key: DesktopLyricsShadowColor) { change in
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 3
            shadow.shadowColor = change.newValue
            shadow.shadowOffset = .zero
            self.firstLineLrcView.shadow = shadow
            self.secondLineLrcView.shadow = shadow
            self.waitingLrcView.shadow = shadow
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observerTokens.forEach() { token in
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func updateFontSize() {
        topInsetConstraint.forEach() { $0.update(offset: insetY) }
        bottomInsetConstraint.forEach() { $0.update(offset: -insetY) }
        leftInsetConstraint.forEach() { $0.update(offset: insetX) }
        rightInsetConstraint.forEach() { $0.update(offset: -insetX) }
        leadingConstraint.forEach() { $0.update(offset: -leading) }
        
        let font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        firstLineLrcView.font = font
        secondLineLrcView.font = font
        waitingLrcView.font = font
        
        backgroundView.layer?.cornerRadius = CGFloat(fontSize / 2)
    }
    
    func updateFontName() {
        let font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        firstLineLrcView.font = font
        secondLineLrcView.font = font
        waitingLrcView.font = font
    }
    
    func displayLrc(_ firstLine: String, secondLine: String) {
        guard enabled == true else {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.secondLineLrcView.stringValue = firstLine
            self.waitingLrcView.stringValue = secondLine
            self.updateConstraints(animated: true)
            self.updateVisibility(animated: true)
            self.backgroundView.layoutSubtreeIfNeeded()
        }, completionHandler: {
            self.firstLineLrcView.stringValue = firstLine
            self.secondLineLrcView.stringValue = secondLine
            self.updateConstraints(animated: false)
            self.updateVisibility(animated: false)
            self.backgroundView.layoutSubtreeIfNeeded()
        })
    }
    
    // MARK: Layout
    
    var insetX: Int {
        return fontSize
    }
    var insetY: Int {
        return fontSize / 3
    }
    var leading: Int {
        return fontSize * 3 / 2
    }
    
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
        
        updateConstraints(animated: false)
        
        backgroundView.snp.makeConstraints() { make in
            let heightFromDock = Preference[DesktopLyricsHeighFromDock]
            make.centerX.equalToSuperview()
            lyricsHeightConstraint = make.bottom.equalToSuperview().offset(-heightFromDock).constraint
        }
    }
    
    func updateConstraints(animated: Bool) {
        if animated {
            normalConstraint.forEach() { $0.deactivate() }
            animatedConstraint.forEach() { $0.activate() }
        } else {
            normalConstraint.forEach() { $0.activate() }
            animatedConstraint.forEach() { $0.deactivate() }
        }
    }
    
    func updateVisibility(animated: Bool) {
        guard enabled == true else {
            backgroundView.isHidden = true
            return
        }
        backgroundView.isHidden = false
        
        if animated {
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
    }
    
}
