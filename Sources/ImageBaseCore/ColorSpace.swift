//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation

public enum ColorSpace {
    
    case p3
    case sRGB
    
    var fromXYZ: DMatrix3x3 {
        switch self {
            case .p3: return .displayP3
            case .sRGB: return .sRGB
        }
    }
    
    var toXYZ: DMatrix3x3 {
        switch self {
            case .p3: return .displayP3Inv
            case .sRGB: return .sRGBInv
        }
    }
    
    public func matrix(to other: ColorSpace) -> DMatrix3x3 {
        return other.fromXYZ * self.toXYZ
    }
    
}
