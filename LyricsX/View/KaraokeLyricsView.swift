//
//  KaraokeLyricsView.swift
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
import SnapKit

class KaraokeLyricsView: NSBox {
    
    private let stackView = NSStackView().then {
        $0.orientation = .vertical
        $0.alignment = .centerX
    }
    
    @objc dynamic var font = NSFont.labelFont(ofSize: 24) { didSet { updateFontSize() } }
    @objc dynamic var textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    @objc dynamic var shadowColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
    
    @objc dynamic var shouldHideWithMouse = true {
        didSet {
            updateTrackingAreas()
        }
    }
    
    var displayLine1: DyeTextField?
    var displayLine2: DyeTextField?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        boxType = .custom
        borderType = .grooveBorder
        borderWidth = 0
        cornerRadius = 12
        contentView = stackView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView = stackView
    }
    
    private func updateFontSize() {
        let insetX = font.pointSize
        let insetY = insetX / 3
        
        stackView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(NSEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX))
        }
        
        cornerRadius = insetX / 2
    }
    
    private func lyricsLabel(_ content: String) -> DyeTextField {
        // TODO: reuse label
        return DyeTextField(string: content).then {
            $0.bind(.font, to: self, withKeyPath: #keyPath(font))
            $0.bind(.textColor, to: self, withKeyPath: #keyPath(textColor))
            $0.bind(.init("dyeColor"), to: self, withKeyPath: #keyPath(shadowColor))
            $0.bind(.init("_shadowColor"), to: self, withKeyPath: #keyPath(shadowColor))
            $0.alphaValue = 0
            $0.isHidden = true
        }
    }
    
    func displayLrc(_ firstLine: String, secondLine: String = "") {
        var toBeHide = stackView.arrangedSubviews as! [DyeTextField]
        var toBeShow: [DyeTextField] = []
        var shouldHideAll = false
        
        if firstLine.isEmpty {
            displayLine1 = nil
            shouldHideAll = true
        } else if toBeHide.count == 2, toBeHide[1].stringValue == firstLine {
            displayLine1 = toBeHide[1]
            toBeHide.remove(at: 1)
        } else {
            let label = lyricsLabel(firstLine)
            displayLine1 = label
            toBeShow.append(label)
        }
        
        if !secondLine.isEmpty {
            let label = lyricsLabel(secondLine)
            displayLine2 = label
            toBeShow.append(label)
        } else {
            displayLine2 = nil
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            context.timingFunction = .mystery
            toBeHide.forEach {
                stackView.removeArrangedSubview($0)
                $0.isHidden = true
                $0.alphaValue = 0
            }
            toBeShow.forEach {
                stackView.addArrangedSubview($0)
                $0.isHidden = false
                $0.alphaValue = 1
            }
            isHidden = shouldHideAll
            layoutSubtreeIfNeeded()
        }, completionHandler: {
            toBeHide.forEach {
                $0.removeFromSuperview()
            }
            self.mouseTest()
        })
    }
    
    // MARK: - Event
    
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingArea.map(removeTrackingArea)
        if shouldHideWithMouse {
            trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .assumeInside, .enabledDuringMouseDrag], owner: self)
            trackingArea.map(addTrackingArea)
        }
        mouseTest()
    }
    
    private func mouseTest() {
        if shouldHideWithMouse,
            let point = NSEvent.mouseLocation(in: self),
            bounds.contains(point) {
            animator().alphaValue = 0.1
        } else {
            animator().alphaValue = 1
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        animator().alphaValue = 0.1
    }
    
    override func mouseExited(with event: NSEvent) {
        animator().alphaValue = 1
    }
    
}

extension NSEvent {
    
    class func mouseLocation(in view: NSView) -> NSPoint? {
        guard let window = view.window else { return nil }
        let windowLocation = window.convertFromScreen(NSRect(origin: NSEvent.mouseLocation, size: .zero)).origin
        return view.convert(windowLocation, from: nil)
    }
}

extension DyeTextField {
    
    @objc dynamic var _shadowColor: NSColor? {
        get {
            return shadow?.shadowColor
        }
        set {
            shadow = newValue.map { color in
                NSShadow().then {
                    $0.shadowBlurRadius = 3
                    $0.shadowColor = color
                    $0.shadowOffset = .zero
                }
            }
        }
    }
}
