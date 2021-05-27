//
//  FontSelectTextField.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Cocoa
import SnapKit

protocol FontSelectTextFieldDelegate: AnyObject {
    
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
            make.bottom.trailing.equalToSuperview().offset(-1)
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
    
    @objc func changeFont(_ sender: Any?) {
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
        let sel = Selector(("validModesForFontPanel"))
        let dummySel = #selector(FontSelectTextField.dummyValidModesForFontPanel)
        guard let dummyIMP = class_getMethodImplementation(cls, dummySel),
            let dummyImpl = class_getInstanceMethod(cls, dummySel),
            let typeEncoding = method_getTypeEncoding(dummyImpl) else {
                fatalError("failed to replace method \(sel) in \(cls)")
        }
        class_replaceMethod(cls, sel, dummyIMP, typeEncoding)
    }()
}
