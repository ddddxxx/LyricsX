//
//  ChineseConverter+Singleton.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import OpenCC

extension ChineseConverter {
    
    static var shared: ChineseConverter? {
        _ = ChineseConverter.observer
        return _shared
    }
    
    private static var _shared: ChineseConverter?
    
    private static let observer = defaults.observe(.chineseConversionIndex, options: [.new, .initial]) { _, change in
        switch change.newValue {
        case 1: ChineseConverter._shared = try! ChineseConverter(option: [.simplify])
        case 2: ChineseConverter._shared = try! ChineseConverter(option: [.traditionalize])
        case 0, _: ChineseConverter._shared = nil
        }
    }
}
