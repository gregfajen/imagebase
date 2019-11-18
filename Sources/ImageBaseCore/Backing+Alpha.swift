//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation

extension ImageBacking {
    
    func removingAlpha() -> ImageBacking {
        guard hasAlpha else { return self }
        fatalError()
    }
    
    var hasAlpha: Bool {
        switch self {
            case .GA, .RGBA, .YCbCrA: return true
            default: return false
        }
    }
    
    func checkIfNeedsAlpha() -> Bool {
        switch self {
            case .GA(let bitmap):
                for y in 0..<bitmap.size.height {
                    for x in 0..<bitmap.size.width {
                        let p = bitmap.sample(x, y)
                        if p.a < 254 {
                            return true
                        }
                    }
                }
                
                return false
            
            
            case .RGBA(let bitmap):
                for y in 0..<bitmap.size.height {
                    for x in 0..<bitmap.size.width {
                        let p = bitmap.sample(x, y)
                        if p.a < 254 {
                            return true
                        }
                    }
                }
                
                return false
            
            
            case .YCbCrA(_, _, _, let bitmap):
                for y in 0..<bitmap.size.height {
                    for x in 0..<bitmap.size.width {
                        let p = bitmap.sample(x, y)
                        if p.v < 254 {
                            return true
                        }
                    }
                }
                
                return false
            
            default: return false
        }
    }
    
}

