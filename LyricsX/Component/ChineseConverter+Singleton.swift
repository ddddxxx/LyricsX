//
//  ChineseConverter+Singleton.swift
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

import OpenCC

extension ChineseConverter {
    
    static var shared: ChineseConverter? {
        _ = ChineseConverter.observer
        return _shared
    }
    
    private static var _shared: ChineseConverter?
    
    private static let observer = defaults.observe(.ChineseConversionIndex, options: [.new, .initial]) { _, change in
        switch change.newValue {
        case 1: ChineseConverter._shared = ChineseConverter(option: [.simplify])
        case 2: ChineseConverter._shared = ChineseConverter(option: [.traditionalize])
        case 0, _: ChineseConverter._shared = nil
        }
    }
}
