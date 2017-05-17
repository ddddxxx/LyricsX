//
//  LyricsXTests.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
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

import XCTest

@testable import LyricsX

class LyricsXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchLyricsPerformance() {
        let testSong = "Rolling in the Deep"
        let testArtist = "Adele"
        let helper = LyricsSourceHelper()
        
        measure {
            var fetchReturnedEx: XCTestExpectation? = self.expectation(description: "fetch lrc")
            let delegate = TextSrc(receivedHandle: {
                fetchReturnedEx?.fulfill()
                fetchReturnedEx = nil
            })
            helper.delegate = delegate
            helper.fetchLyrics(title: testSong, artist: testArtist)
            self.waitForExpectations(timeout: 5) { _ in
                self.stopMeasuring()
            }
        }
    }
    
    func testLyricsSourceAvailability() {
        let testCase = [
            ("Rolling in the Deep", "Adele"),
            ("海阔天空", "Beyond"),
        ]
        
        let lyricsSources: [LyricsSource] = [
            LyricsXiami(),
            LyricsGecimi(),
            LyricsTTPod(),
            Lyrics163(),
            LyricsQQ(),
        ]
        lyricsSources.forEach() { src in
            var fetchReturnedEx: XCTestExpectation? = expectation(description: "fetch from \(src)")
            for song in testCase {
                src.fetchLyrics(title: song.0, artist: song.1) { _ in
                    fetchReturnedEx?.fulfill()
                    fetchReturnedEx = nil
                }
            }
            waitForExpectations(timeout: 5)
        }
    }
    
}

class TextSrc: LyricsSourceDelegate {
    
    private let receivedHandle: (() -> Void)?
    private let completedHandle: (() -> Void)?
    
    init(receivedHandle: (() -> Void)?, completedHandle: (() -> Void)? = nil) {
        self.receivedHandle = receivedHandle
        self.completedHandle = completedHandle
    }
    
    func lyricsReceived(lyrics: Lyrics) {
        receivedHandle?()
    }
    
    func fetchCompleted(result: [Lyrics]) {
        completedHandle?()
    }
    
}
