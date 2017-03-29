//
//  KaraokeLyricsView.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/3/28.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa
import SnapKit

class KaraokeLyricsView: NSBox {
    
    private let firstLineLrcView = NSTextField(labelWithString: "")
    private let secondLineLrcView = NSTextField(labelWithString: "")
    private let waitingLrcView = NSTextField(labelWithString: "")
    
    var firstLine = "LyricsX" {
        didSet { updateDisplay() }
    }
    var secondLine = "" {
        didSet { updateDisplay() }
    }
    var onAnimation = false {
        didSet { updateDisplay() }
    }
    
    dynamic var fontName = "Helvetica Light"
    dynamic var fontSize = 24 { didSet { updateFontSize() } }
    dynamic var textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    dynamic var shadowColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1) {
        didSet {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 3
            shadow.shadowColor = shadowColor
            shadow.shadowOffset = .zero
            firstLineLrcView.shadow = shadow
            secondLineLrcView.shadow = shadow
            waitingLrcView.shadow = shadow
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        firstLineLrcView.alignment = .center
        secondLineLrcView.alignment = .center
        waitingLrcView.alignment = .center
        
        firstLineLrcView.bind(NSFontNameBinding, to: self, withKeyPath: "fontName", options: nil)
        secondLineLrcView.bind(NSFontNameBinding, to: self, withKeyPath: "fontName", options: nil)
        waitingLrcView.bind(NSFontNameBinding, to: self, withKeyPath: "fontName", options: nil)
        
        firstLineLrcView.bind(NSFontSizeBinding, to: self, withKeyPath: "fontSize", options: nil)
        secondLineLrcView.bind(NSFontSizeBinding, to: self, withKeyPath: "fontSize", options: nil)
        waitingLrcView.bind(NSFontSizeBinding, to: self, withKeyPath: "fontSize", options: nil)
        
        firstLineLrcView.bind(NSTextColorBinding, to: self, withKeyPath: "textColor", options: nil)
        secondLineLrcView.bind(NSTextColorBinding, to: self, withKeyPath: "textColor", options: nil)
        waitingLrcView.bind(NSTextColorBinding, to: self, withKeyPath: "textColor", options: nil)
        
        self.addSubview(firstLineLrcView)
        self.addSubview(secondLineLrcView)
        self.addSubview(waitingLrcView)
        
        makeConstraints()
    }
    
    private func updateFontSize() {
        let insetX = fontSize
        let insetY = fontSize / 3
        let leading = fontSize * 3 / 2
        
        topInsetConstraint.forEach() { $0.update(offset: insetY) }
        bottomInsetConstraint.forEach() { $0.update(offset: -insetY) }
        leftInsetConstraint.forEach() { $0.update(offset: insetX) }
        rightInsetConstraint.forEach() { $0.update(offset: -insetX) }
        leadingConstraint.forEach() { $0.update(offset: -leading) }
        
        cornerRadius = CGFloat(fontSize / 2)
    }
    
    // MARK: - Layout
    
    private var constraintsForAnimation: [Bool: [SnapKit.Constraint]] = [:]
    private var constraintsForLyrics: [NSTextField: [SnapKit.Constraint]] = [:]
    
    private var topInsetConstraint: [SnapKit.Constraint] = []
    private var bottomInsetConstraint: [SnapKit.Constraint] = []
    private var leftInsetConstraint: [SnapKit.Constraint] = []
    private var rightInsetConstraint: [SnapKit.Constraint] = []
    
    private var leadingConstraint: [SnapKit.Constraint] = []
    
    private func makeConstraints() {
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
            constraintsForAnimation[false] = [cons1, cons2, cons3, cons4]
            
            constraintsForLyrics[firstLineLrcView] = [cons3]
            
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
            constraintsForAnimation[false]! += [cons1, cons2]
            
            let cons3 = make.top.equalToSuperview().offset(insetY).priority(750).constraint
            let cons4 = make.bottom.equalToSuperview().offset(-insetY).priority(500).constraint
            constraintsForAnimation[true] = [cons3, cons4]
            
            constraintsForLyrics[secondLineLrcView] = [cons2, cons3]
            
            topInsetConstraint += [cons1, cons3]
            bottomInsetConstraint += [cons2, cons4]
        }
        
        waitingLrcView.snp.makeConstraints() { make in
            make.centerX.equalToSuperview()
            
            let cons1 = make.left.greaterThanOrEqualToSuperview().offset(insetX).constraint
            let cons2 = make.right.lessThanOrEqualToSuperview().offset(-insetX).constraint
            
            let cons3 = make.top.equalToSuperview().offset(insetY).priority(500).constraint
            let cons4 = make.bottom.equalToSuperview().offset(-insetY).priority(750).constraint
            constraintsForAnimation[true]! += [cons1, cons2, cons3, cons4]
            
            constraintsForLyrics[waitingLrcView] = [cons4]
            
            topInsetConstraint += [cons3]
            bottomInsetConstraint += [cons4]
            leftInsetConstraint += [cons1]
            rightInsetConstraint += [cons2]
        }
        
        updateDisplay()
    }
    
    private func updateDisplay() {
        let upperView: NSTextField
        let lowerView: NSTextField
        let alternateView: NSTextField
        if onAnimation {
            upperView = secondLineLrcView
            lowerView = waitingLrcView
            alternateView = firstLineLrcView
        } else {
            upperView = firstLineLrcView
            lowerView = secondLineLrcView
            alternateView = waitingLrcView
        }
        
        constraintsForAnimation[onAnimation]!.forEach() { $0.activate() }
        constraintsForAnimation[!onAnimation]!.forEach() { $0.deactivate() }
        
        upperView.alphaValue = 1
        lowerView.alphaValue = 1
        alternateView.alphaValue = 0
        
        upperView.stringValue = firstLine
        lowerView.stringValue = secondLine
        
        guard firstLine != "" else {
            upperView.isHidden = true
            constraintsForLyrics[upperView]?.forEach() { $0.deactivate() }
            alphaValue = 0
            return
        }
        upperView.isHidden = false
        alphaValue = 1
        
        guard secondLine != "" else {
            lowerView.isHidden = true
            constraintsForLyrics[lowerView]?.forEach() { $0.deactivate() }
            return
        }
        lowerView.isHidden = false
    }
    
}
