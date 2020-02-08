//
//  CFExtension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

// MARK: - CFStringTokenizer

extension NSString {
    
    var dominantLanguage: String? {
        let cfStr = self as CFString
        return CFStringTokenizerCopyBestStringLanguage(cfStr, cfStr.fullRange) as String?
    }
}

extension CFStringTokenizer {
    
    func currentFuriganaAnnotation(in string: NSString) -> (NSString, NSRange)? {
        let range = currentTokenRange()
        let tokenStr = string.substring(with: range.asNS)
        guard tokenStr.unicodeScalars.contains(where: CharacterSet.kanji.contains),
            let latin = currentTokenAttribute(.latinTranscription)?.asNS,
            let hiragana = latin.applyingTransform(.latinToHiragana, reverse: false),
            let (rangeToAnnotate, rangeInAnnotation) = rangeOfUncommonContent(tokenStr, hiragana) else {
                return nil
        }
        let annotation = String(hiragana[rangeInAnnotation]) as NSString
        var nsrangeToAnnotate = NSRange(rangeToAnnotate, in: tokenStr)
        nsrangeToAnnotate.location += range.location
        return (annotation, nsrangeToAnnotate)
    }
}

private func rangeOfUncommonContent(_ s1: String, _ s2: String) -> (Range<String.Index>, Range<String.Index>)? {
    guard s1 != s2, !s1.isEmpty, !s2.isEmpty else {
        return nil
    }
    var (l1, l2) = (s1.startIndex, s2.startIndex)
    while s1[l1] == s2[l2] {
        guard let nl1 = s1.index(l1, offsetBy: 1, limitedBy: s1.endIndex),
            let nl2 = s2.index(l2, offsetBy: 1, limitedBy: s2.endIndex) else {
                break
        }
        (l1, l2) = (nl1, nl2)
    }
    
    var (r1, r2) = (s1.endIndex, s2.endIndex)
    repeat {
        guard let nr1 = s1.index(r1, offsetBy: -1, limitedBy: s1.startIndex),
            let nr2 = s2.index(r2, offsetBy: -1, limitedBy: s2.startIndex) else {
                break
        }
        (r1, r2) = (nr1, nr2)
    } while s1[r1] == s2[r2]
    
    let range1 = (l1...r1).relative(to: s1.indices)
    let range2 = (l2...r2).relative(to: s2.indices)
    return (range1, range2)
}
