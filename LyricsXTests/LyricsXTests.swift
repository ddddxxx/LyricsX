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
    
    let testSong = "Lovesong"
    let testArtist = "Adele"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLyricsLoad() {
        let source = LyricsXiami()
        
        self.measure {
            let result = source.fetchLyrics(title: self.testSong, artist: self.testArtist)
            XCTAssert(result.count > 0)
        }
    }
    
}
