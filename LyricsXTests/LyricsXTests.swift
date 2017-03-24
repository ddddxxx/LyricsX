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
