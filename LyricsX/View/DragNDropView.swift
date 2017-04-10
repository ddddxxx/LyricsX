//
//  DragNDropView.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/4/10.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

protocol DragNDropDelegate: class {
    func dragFinished(content: String)
}

class DragNDropView: NSView {
    
    weak var dragDelegate: DragNDropDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSStringPboardType, NSFilenamesPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        
        if pboard.types?.contains(NSStringPboardType) == true,
            let str = pboard.string(forType: NSStringPboardType) {
            dragDelegate?.dragFinished(content: str)
            Swift.print(str)
            return true
        }
        
        if pboard.types?.contains(NSFilenamesPboardType) == true,
            let files = pboard.propertyList(forType: NSFilenamesPboardType) as? [Any],
            let path = files.first as? String,
            let str = try? String(contentsOf: URL(fileURLWithPath: path)) {
            dragDelegate?.dragFinished(content: str)
            Swift.print(str)
            return true
        }
        
        return false
    }
    
}
