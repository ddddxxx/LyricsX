//
//  KaraokeLyricsView.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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
    
    private let stackView = NSStackView()
    
    dynamic var fontName = "Helvetica Light"
    dynamic var fontSize = 24 { didSet { updateFontSize() } }
    dynamic var textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    dynamic var shadowColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1) {
        didSet {
            let shadow = NSShadow().then {
                $0.shadowBlurRadius = 3
                $0.shadowColor = shadowColor
                $0.shadowOffset = .zero
            }
            for label in stackView.subviews {
                label.shadow = shadow
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isHidden = true
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        addSubview(stackView)
        
        updateFontSize()
    }
    
    private func updateFontSize() {
        let insetX = CGFloat(fontSize)
        let insetY = insetX / 3
        
        stackView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(EdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX))
        }
        
        cornerRadius = insetX / 2
    }
    
    private func lyricsLabel(_ content: String) -> NSTextField {
        // TODO: reuse label
        let shadow = NSShadow().then {
            $0.shadowBlurRadius = 3
            $0.shadowColor = shadowColor
            $0.shadowOffset = .zero
        }
        return NSTextField(labelWithString: content).then {
            $0.bind(NSFontNameBinding, to: self, withKeyPath: #keyPath(fontName))
            $0.bind(NSFontSizeBinding, to: self, withKeyPath: #keyPath(fontSize))
            $0.bind(NSTextColorBinding, to: self, withKeyPath: #keyPath(textColor))
            $0.shadow = shadow
            $0.alphaValue = 0
            $0.isHidden = true
        }
    }
    
    func displayLrc(_ firstLine: String, secondLine: String = "") {
        var toBeHide = stackView.subviews as! [NSTextField]
        var toBeShow: [NSTextField] = []
        var shouldHideAll = false
        
        if firstLine.isEmpty {
            shouldHideAll = true
        } else if toBeHide.count == 2, toBeHide[1].stringValue == firstLine {
            toBeHide.remove(at: 1)
        } else {
            let label = lyricsLabel(firstLine)
            stackView.addView(label, in: .bottom)
            toBeShow.append(label)
        }
        
        if !secondLine.isEmpty {
            let label = lyricsLabel(secondLine)
            stackView.addView(label, in: .bottom)
            toBeShow.append(label)
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            context.timingFunction = .mystery
            toBeHide.forEach {
                $0.removeFromSuperview()
            }
            toBeShow.forEach {
                $0.isHidden = false
                $0.alphaValue = 1
            }
            isHidden = shouldHideAll
            window?.layoutIfNeeded()
        })
    }
    
}

extension NSTextField {
    
    @available(macOS, obsoleted: 10.12)
    convenience init(labelWithString stringValue: String) {
        self.init()
        self.stringValue = stringValue
        isEditable = false
        isSelectable = false
        textColor = .labelColor
        backgroundColor = .controlColor
        drawsBackground = false
        isBezeled = false
        alignment = .natural
        font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
        lineBreakMode = .byClipping
        cell?.isScrollable = true
        cell?.wraps = false
    }
}
