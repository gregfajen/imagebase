//
//  IntAffineTransform.swift
//  muze
//
//  Created by Greg Fajen on 5/30/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

#if os(macOS)
import Cocoa
#elseif os(Linux)
import Foundation
#else
import UIKit
typealias ImageOrientation = UIImage.Orientation
#endif

#if os(macOS) || os(Linux)
public enum ImageOrientation : UInt8, Hashable {
    
    case up = 1
    case upMirrored
    
    case down
    case downMirrored
    
    case right
    case rightMirrored
    
    case left
    case leftMirrored
    
}
#endif

struct IntAffineTransform: CustomDebugStringConvertible, Equatable {
    
    let a,b,c,d,x,y: Int16
    
    init(_ a: Int16,_ b: Int16,_ c: Int16, _ d: Int16, _ x: Int16, _ y: Int16) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.x = x
        self.y = y
    }
    
//    init(_ transform: CGAffineTransform) {
//        self.init(Int16(round(transform.a)),
//                  Int16(round(transform.b)),
//                  Int16(round(transform.c)),
//                  Int16(round(transform.d)),
//                  Int16(round(transform.tx)),
//                  Int16(round(transform.ty)))
//    }
    
    static let identity = IntAffineTransform(1,0,0,1,0,0)
    
//    var inverse: IntAffineTransform {
//        return IntAffineTransform(cg.inverted())
//    }
    
//    var cg: CGAffineTransform {
//        return CGAffineTransform(a: CGFloat(a),
//                                 b: CGFloat(b),
//                                 c: CGFloat(c),
//                                 d: CGFloat(d),
//                                tx: CGFloat(x),
//                                ty: CGFloat(y))
//    }
    
    var debugDescription: String {
        return "\(array)"
    }
    
    var array: [Int16] { return [a,b,c,d,x,y] }
    
}

extension ImageOrientation {
    
    static var all: [ImageOrientation] {
        return [.up, .upMirrored, .left, .leftMirrored, .right, .rightMirrored, .down, .downMirrored]
    }
    
    func transform(for size: Size) -> IntAffineTransform {
        let w = Int16(size.width)
        let h = Int16(size.height)
        switch self {
            case .up:            return IntAffineTransform( 1, 0, 0,  1,   0, 0)
            case .upMirrored:    return IntAffineTransform(-1, 0, 0,  1, w-1, 0)

            case .down:          return IntAffineTransform(-1, 0, 0, -1, w-1, h-1)
            case .downMirrored:  return IntAffineTransform(1,  0, 0, -1,   0, h-1)

            case .right:         return IntAffineTransform(0,  1, 1,  0,   0, 0) // 5
            case .rightMirrored: return IntAffineTransform(0, -1, 1,  0,  0, h-1) // 6

            case .left:          return IntAffineTransform(0,  -1, -1, 0, w-1, h-1)
            case .leftMirrored:  return IntAffineTransform(0,  1, -1, 0,   w-1, 0)
        }
    }
    
    func inverseTransform(for size: Size) -> IntAffineTransform {
        let w = Int16(size.width)
        let h = Int16(size.height)
        switch self {
            case .up:            return IntAffineTransform( 1, 0, 0,  1,   0, 0)
            case .upMirrored:    return IntAffineTransform(-1, 0, 0,  1, w-1, 0)
            
            case .down:          return IntAffineTransform(-1, 0, 0, -1, w-1, h-1)
            case .downMirrored:  return IntAffineTransform(1,  0, 0, -1,   0, h-1)
                
            case .right:         return IntAffineTransform(0,  1, 1,  0,   0, 0) // 5
            case .rightMirrored: return IntAffineTransform(0, 1, -1,  0,  h-1, 0) // 6
                
            case .left:          return IntAffineTransform(0,  -1, -1, 0, h-1, w-1)
            case .leftMirrored:  return IntAffineTransform(0,  -1, 1, 0,   0, w-1)
        }
    }
}


