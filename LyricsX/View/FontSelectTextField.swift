//
//  FontSelectTextField.swift
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

protocol FontSelectTextFieldDelegate: class {
    
    func fontChanged(from oldFont: NSFont, to newFont: NSFont, sender: FontSelectTextField)
}

class FontSelectTextField: NSTextField, NSWindowDelegate {
    
    weak var fontChangeDelegate: FontSelectTextFieldDelegate?
    
    @objc dynamic var selectedFont = NSFont.systemFont(ofSize: NSFont.systemFontSize) {
        didSet {
            stringValue = "\(selectedFont.fontName) - \(Int(selectedFont.pointSize))"
        }
    }
    
    override var isEditable: Bool {
        get { return false }
        set {}
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _ = FontSelectTextField.swizzler
        let btn = NSButton(frame: .zero).then { btn in
            btn.bezelStyle = .regularSquare
            btn.setButtonType(.momentaryPushIn)
            btn.isBordered = false
            btn.imagePosition = .imageOnly
            btn.image = #imageLiteral(resourceName: "font_panel")
            btn.target = self
            btn.action = #selector(showFontPanel)
        }
        addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.bottom.right.equalToSuperview().offset(-1)
        }
    }
    
    deinit {
        let fontManger = NSFontManager.shared
        if fontManger.target === self {
            fontManger.target = nil
            NSFontPanel.shared.close()
        }
    }
    
    @objc private func showFontPanel(_ sender: NSButton) {
        let fontManger = NSFontManager.shared
        fontManger.target = self
        fontManger.setSelectedFont(selectedFont, isMultiple: false)
        let fontPanel = fontManger.fontPanel(true)
        fontPanel?.delegate = self
        fontPanel?.makeKeyAndOrderFront(self)
    }
    
    override func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else {
            return
        }
        let newFont = manager.convert(selectedFont)
        fontChangeDelegate?.fontChanged(from: selectedFont, to: newFont, sender: self)
        selectedFont = newFont
    }
    
    @objc private func dummyValidModesForFontPanel(_ fontPanel: NSFontPanel) -> UInt32 {
        return NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelFaceModeMask
    }
    
    private static let swizzler: Void = {
        let cls = FontSelectTextField.self
        let sel = #selector(NSObject.validModesForFontPanel)
        let dummySel = #selector(FontSelectTextField.dummyValidModesForFontPanel)
        guard let dummyIMP = class_getMethodImplementation(cls, dummySel),
            let dummyImpl = class_getInstanceMethod(cls, dummySel),
            let typeEncoding = method_getTypeEncoding(dummyImpl) else {
                fatalError("failed to replace method \(sel) in \(cls)")
        }
        class_replaceMethod(cls, sel, dummyIMP, typeEncoding)
    }()
}
