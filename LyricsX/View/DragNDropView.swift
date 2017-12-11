//
//  DragNDropView.swift
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

protocol DragNDropDelegate: class {
    func dragFinished(content: String)
}

class DragNDropView: NSView {
    
    weak var dragDelegate: DragNDropDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.string, .fileNames])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        
        if pboard.types?.contains(.string) == true,
            let str = pboard.string(forType: .string) {
            dragDelegate?.dragFinished(content: str)
            return true
        }
        
        if pboard.types?.contains(.fileNames) == true,
            let files = pboard.propertyList(forType: .fileNames) as? [Any],
            let path = files.first as? String,
            let str = try? String(contentsOf: URL(fileURLWithPath: path)) {
            dragDelegate?.dragFinished(content: str)
            return true
        }
        
        return false
    }
    
}

extension NSPasteboard.PasteboardType {
    static let fileNames = NSPasteboard.PasteboardType("NSFilenamesPboardType")
}
