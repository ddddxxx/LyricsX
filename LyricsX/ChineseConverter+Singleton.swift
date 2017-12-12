//
//  ChineseConverter+Singleton.swift
//  LyricsX
//
//  Created by 邓翔 on 2017/12/12.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import OpenCC

extension ChineseConverter {
    
    static var shared: ChineseConverter? = {
        _ = ChineseConverter.observer
        return nil
    }()
    
    private static let observer = defaults.observe(.ChineseConversionIndex, options: [.new]) { _, change in
        switch change.newValue {
        case 1?:
            ChineseConverter.shared = ChineseConverter(option: [.simplify])
        case 2?:
            ChineseConverter.shared = ChineseConverter(option: [.traditionalize])
        default:
            ChineseConverter.shared = nil
        }
    }
}
