//
//  StringUtility.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/1/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import Foundation

func indexOf(_ token : String, _ source : String, _ endIndex : Bool = false) -> Int {
    let sourceChars = Array(source.characters)
    let tokenChars  = Array(token.characters)
    
    for i in 0 ..< sourceChars.count {
        
        if (sourceChars[i] == tokenChars[0]) {
            var found = true
            
            for j in 0 ..< tokenChars.count {
                if (tokenChars[j] != sourceChars[i + j]) {
                    found = false
                    break
                }
            }
            
            // Match found!
            if (found) {
                if (endIndex) {
                    return i + tokenChars.count
                }
                return i
            }
        }
    }
    
    return -1
}
