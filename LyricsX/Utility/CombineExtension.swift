//
//  BasicExtension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2020  Xander Deng. Licensed under GPLv3.
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
