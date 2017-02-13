//
//  LyricsXTests.swift
//  LyricsXTests
//
//  Created by 邓翔 on 2017/2/8.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import XCTest

@testable import LyricsX

class LyricsXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchLyrics() {
        let testSong = "Rolling in the Deep"
        let testArtist = "Adele"
        measure {
            let fetchReturnedExpectation = self.expectation(description: "fetch lrc")
            LyricsSourceHelper().fetchLyrics(title: testSong, artist: testArtist) {
                fetchReturnedExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 5) { _ in
                self.stopMeasuring()
            }
        }
    }
    
    func testLyricsSourceAvailability() {
        let testCase = [
            ("Rolling in the Deep", "Adele"),
            ("海阔天空", "Beyond")
        ]
        
        let lyricsSources: [LyricsSource] = [
            LyricsXiami(),
            LyricsGecimi(),
            LyricsTTPod()
        ]
        
        lyricsSources.forEach() { src in
            let fetchResule = testCase.flatMap() { song in
                return src.fetchLyrics(title: song.0, artist: song.1)
            }
            XCTAssert(fetchResule.count > 0)
        }
    }
    
}
