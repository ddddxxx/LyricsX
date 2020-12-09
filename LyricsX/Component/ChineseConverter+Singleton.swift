//
//  ChineseConverter+Singleton.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
