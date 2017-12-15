//
//  ChineseConverter+Singleton.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/12/12.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import OpenCC

extension ChineseConverter {
    
    static var shared: ChineseConverter? {
        _ = ChineseConverter.observer
        return _shared
    }
    
    private static var _shared: ChineseConverter?
    
    private static let observer = defaults.observe(.ChineseConversionIndex, options: [.new, .initial]) { _, change in
        switch change.newValue {
        case 1?: ChineseConverter._shared = ChineseConverter(option: [.simplify])
        case 2?: ChineseConverter._shared = ChineseConverter(option: [.traditionalize])
        default: ChineseConverter._shared = nil
        }
    }
}
