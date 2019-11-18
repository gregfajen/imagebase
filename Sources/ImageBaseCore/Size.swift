//
//  Size.swift
//  App
//
//  Created by Greg Fajen on 11/14/19.
//

import Foundation
//import SwiftGD

public struct Size: Equatable, Hashable {
    
    public let width: Int
    public let height: Int
    
    public init<T: FixedWidthInteger>( _ width: T, _ height: T) {
        self.width = Int(width)
        self.height = Int(height)
    }
    
}

extension ImageOrientation {
    
    var isLeftOrRight: Bool {
        switch self {
            case .left: return true
            case .right: return true
            case .leftMirrored: return true
            case .rightMirrored: return true
            default: return false
        }
    }
    
}

extension Size {
    
    func after(_ orientation: ImageOrientation) -> Size {
        if orientation.isLeftOrRight {
            return Size(height, width)
        } else {
            return self
        }
    }
    
}

//extension SwiftGD.Size {
//    
//    func after(_ orientation: ImageOrientation) -> Size {
//        if orientation.isLeftOrRight {
//            return Size(height, width)
//        } else {
//            return Size(width, height)
//        }
//    }
//    
//}
