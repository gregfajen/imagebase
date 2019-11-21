//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/21/19.
//

import Foundation

public extension ImageBacking {
    
    func as8Bit() -> ImageBacking<UInt8> {
        switch self {
            case .G(let Y):
                return .G(Y.as8Bit())
            case .GA(let YA):
                return .GA(YA.as8Bit())
            
            case .RGB(let RGB):
                return .RGB(RGB.as8Bit())
            case .RGBA(let RGBA):
                return .RGBA(RGBA.as8Bit())
            
            case .YCbCr(let Y, let Cb, let Cr):
                return .YCbCr(Y.as8Bit(), Cb.as8Bit(), Cr.as8Bit())
            case .YCbCrA(let Y, let Cb, let Cr, let A):
                return .YCbCrA(Y.as8Bit(), Cb.as8Bit(), Cr.as8Bit(), A.as8Bit())
        }
    }
    
}

public extension Bitmap {
    
    func as8Bit() -> Bitmap<P.Eight> {
        if let self = self as? Bitmap<P.Eight> { return self }
        
        return map { $0.eight }
    }
    
}
