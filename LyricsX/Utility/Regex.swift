//
//  Regex.swift
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

import Foundation

// MARK: MatchResult

// swiftlint:disable identifier_name

struct MatchResult {
    
    struct Capture: Equatable, Hashable {
        let range: NSRange
        let content: Substring
        
        var string: String {
            return String(content)
        }
    }
    
    let captures: [Capture?]
    
    fileprivate init(result: NSTextCheckingResult, in string: String) {
        guard result.range.location != NSNotFound else {
            captures = []
            return
        }
        captures = (0..<result.numberOfRanges).map { index in
            let nsrange = result.range(at: index)
            guard nsrange.location != NSNotFound else { return nil }
            let r = Range(nsrange, in: string)!
            return Capture(range: nsrange, content: string[r])
        }
    }
}

extension MatchResult {
    
    var range: NSRange {
        return captures.first!!.range
    }
    
    var content: Substring {
        return captures.first!!.content
    }
    
    var string: String {
        return String(content)
    }
    
    subscript(_ captureGroupIndex: Int) -> Capture? {
        return captures[captureGroupIndex]
    }
}

// MARK: Regex

struct Regex {
    
    private let _regex: NSRegularExpression
    
    init(_ pattern: String, options: NSRegularExpression.Options = []) throws {
        _regex = try NSRegularExpression(pattern: pattern, options: options)
    }
}

extension Regex {
    
    var pattern: String {
        return _regex.pattern
    }
    
    var options: NSRegularExpression.Options {
        return _regex.options
    }
    
    var numberOfCaptureGroups: Int {
        return _regex.numberOfCaptureGroups
    }
    
    static func escapedPattern(for string: String) -> String {
        return NSRegularExpression.escapedPattern(for: string)
    }
}

extension Regex {
    
    func enumerateMatches(in string: String,
                          options: NSRegularExpression.MatchingOptions = [],
                          range: NSRange? = nil,
                          using block: (_ result: MatchResult?, _ flags: NSRegularExpression.MatchingFlags, _ stop: inout Bool) -> Void) {
        _regex.enumerateMatches(in: string, options: options, range: range ?? string.fullRange) { result, flags, stop in
            let r = result.map { MatchResult(result: $0, in: string) }
            var s = false
            block(r, flags, &s)
            stop.pointee = ObjCBool(s)
        }
    }
    
    func matches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> [MatchResult] {
        return _regex.matches(in: string, options: options, range: range ?? string.fullRange).map {
            MatchResult(result: $0, in: string)
        }
    }
    
    func numberOfMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> Int {
        return _regex.numberOfMatches(in: string, options: options, range: range ?? string.fullRange)
    }
    
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> MatchResult? {
        return _regex.firstMatch(in: string, options: options, range: range ?? string.fullRange).map {
            MatchResult(result: $0, in: string)
        }
    }
    
    func isMatch(_ string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> Bool {
        return _regex.firstMatch(in: string, options: options, range: range ?? string.fullRange) != nil
    }
}

extension Regex {
    
    func replacingMatches(in string: String,
                          options: NSRegularExpression.MatchingOptions = [],
                          range: NSRange? = nil,
                          withTemplate templ: String) -> String {
        return _regex.stringByReplacingMatches(in: string, options: options, range: range ?? string.fullRange, withTemplate: templ)
    }
    
    func replaceMatches(in string: inout String,
                        options: NSRegularExpression.MatchingOptions = [],
                        range: NSRange? = nil,
                        withTemplate templ: String) -> Int {
        let mutableString = NSMutableString(string: string)
        let result = _regex.replaceMatches(in: mutableString, options: options, range: range ?? mutableString.fullRange, withTemplate: templ)
        string = mutableString as String
        return result
    }
}

// MARK: Conformances

extension MatchResult: Equatable, Hashable {
    
    static func == (lhs: MatchResult, rhs: MatchResult) -> Bool {
        return lhs.captures.elementsEqual(rhs.captures, by: ==)
    }
    
    public func hash(into hasher: inout Hasher) {
        captures.forEach { hasher.combine($0) }
    }
}

extension Regex: Equatable, Hashable {
    
    static func == (lhs: Regex, rhs: Regex) -> Bool {
        return lhs._regex == rhs._regex
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_regex)
    }
}
