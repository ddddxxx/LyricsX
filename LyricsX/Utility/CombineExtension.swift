//
//  CombineExtension.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CXShim

extension Publisher {
    
    func signal() -> Publishers.Map<Self, Void> {
        return self.map { _ in Void() }
    }
}

extension Publisher where Output == Void {
    
    func prepend() -> Publishers.Concatenate<Publishers.Sequence<[Void], Failure>, Self> {
        prepend(())
    }
}
