//
//  KMP.swift
//  iOSExamples
//
//  Created by Dawand Sulaiman on 30/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

// used for KMP, Build pi function of prefixes
fileprivate func build_pi(_ str: String) -> [Int] {
    let n = str.characters.count
    var pi = Array(repeating: 0, count: n + 1)
    var k:Int = -1
    pi[0] = -1
    
    for i in 0..<n {
        while (k >= 0 && (str[str.characters.index(str.startIndex, offsetBy: k)] != str[str.characters.index(str.startIndex, offsetBy: i)])) {
            k = pi[k]
        }
        k+=1
        pi[i + 1] = k
    }
    
    return pi
}

// Knuth-Morris Pratt algorithm
public func KMP(_ text:String, pattern: String) -> [Int] {
    let start = CFAbsoluteTimeGetCurrent()
    
    // Convert to Character array to index in O(1)
    var patt = Array(pattern.characters)
    var S = Array(text.characters)
    
    var matches = [Int]()
    let n = text.characters.count
    
    let m = pattern.characters.count
    var k = 0
    var pi = build_pi(pattern)
    
    for i in 0..<n {
        while (k >= 0 && (k == m || patt[k] != S[i])) {
            k = pi[k]
        }
        k += 1
        if (k == m) {
            matches.append(i - m + 1)
        }
    }
    
    let stopTime = CFAbsoluteTimeGetCurrent()
    
    debugPrint("Searching the file time: \(stopTime - start)")

    return matches
}
