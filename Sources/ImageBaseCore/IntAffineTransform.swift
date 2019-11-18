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
    
    case left
    case leftMirrored
    
    case right
    case rightMirrored
    
}
#endif

struct IntAffineTransform: CustomDebugStringConvertible {
    
    let a,b,c,d,x,y: Int16
    
    init(_ a: Int16,_ b: Int16,_ c: Int16, _ d: Int16, _ x: Int16, _ y: Int16) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.x = x
        self.y = y
    }
    
    init(_ transform: CGAffineTransform) {
        self.init(Int16(round(transform.a)),
                  Int16(round(transform.b)),
                  Int16(round(transform.c)),
                  Int16(round(transform.d)),
                  Int16(round(transform.tx)),
                  Int16(round(transform.ty)))
    }
    
//    init(_ transform: AffineTransform) {
//        self.init(transform.cg)
//    }
    
    static let identity = IntAffineTransform(1,0,0,1,0,0)
    
    var inverse: IntAffineTransform {
        return IntAffineTransform(cg.inverted())
    }
    
    var cg: CGAffineTransform {
        return CGAffineTransform(a: CGFloat(a),
                                 b: CGFloat(b),
                                 c: CGFloat(c),
                                 d: CGFloat(d),
                                tx: CGFloat(x),
                                ty: CGFloat(y))
    }
    
    var debugDescription: String {
        return "\(array)"
    }
    
    var array: [Int16] { return [a,b,c,d,x,y] }
    
}

//extension IntAffineTransform: MetalBuffer {
//
//    var length: Int { return 16 }
//    var asData: Data { return padded.asData }
//
//    var array: [Int16] { return [a,b,c,d,x,y] }
//    var padded: [Int16] { return array + [0,0] }
//
//}
//
//extension Int16: MetalBuffer {
//
//    var length: Int { return 2 }
//    var asData: Data { fatalError() /*return Data(from: self)*/ }
//
//}

extension ImageOrientation {
    
    static var all: [ImageOrientation] {
        return [.up, .upMirrored, .left, .leftMirrored, .right, .rightMirrored, .down, .downMirrored]
    }
    
    
    func transform(for size: Size) -> IntAffineTransform {
        return inverseTransform(for: size).inverse
    }
    
    func inverseTransform(for size: Size) -> IntAffineTransform {
        let w = Int16(size.width)
        let h = Int16(size.height)
        switch self {
            case .up:            return IntAffineTransform( 1, 0, 0,  1,   0, 0)
            case .upMirrored:    return IntAffineTransform(-1, 0, 0,  1, w-1, 0)
                
            case .left:          return IntAffineTransform(0, -1, 1,  0, w-1, 0)
            case .leftMirrored:  return IntAffineTransform(0,  1, 1,  0,   0, 0)
                
            case .right: return IntAffineTransform(0,  1, -1, 0,   0, h-1)
            case .rightMirrored:         return IntAffineTransform(0, -1, -1, 0, w-1, h-1)
            
            case .down:          return IntAffineTransform(-1, 0, 0, -1, w-1, h-1)
            case .downMirrored:  return IntAffineTransform(1,  0, 0, -1,   0, h-1)
        }
    }
}

#if os(iOS)
extension ImageOrientation {
    static var originalImage2: UIImage {
        return UIImage(size: CGSize(2), scale: 1, block: {
            UIColor.green.set()
            UIRectFill(CGRect(x: 0, y: 0, width: 2, height: 1))
            
            UIColor.red.set()
            UIRectFill(CGRect(x: 0, y: 1, width: 1, height: 1))
            
            UIColor.blue.set()
            UIRectFill(CGRect(x: 1, y: 1, width: 1, height: 1))
        })
    }
    
    static var originalImage3: UIImage {
        return UIImage(size: CGSize(width: 2, height: 3), scale: 1, block: {
            UIColor.red.set()
            UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
            
            UIColor.green.set()
            UIRectFill(CGRect(x: 0, y: 1, width: 1, height: 1))
            
            UIColor.blue.set()
            UIRectFill(CGRect(x: 0, y: 2, width: 1, height: 1))
            
            UIColor.black.set()
            UIRectFill(CGRect(x: 1, y: 0, width: 1, height: 3))
        })
    }
    
    static func test() {
        test1()
        test2()
        test3()
    }
    
    static func test1() {
        let originalImage = UIImage(size: CGSize(width: 1, height: 2), scale: 1, block: { })
        
        for orientation in all {
            let image = UIImage.init(cgImage: originalImage.cgImage!, scale: 1, orientation: orientation)
            
            print("ORIENTATION: \(orientation)")
            
            let transform = orientation.transform(for: originalImage.size)
            let newCorners: [CGPoint] = (.zero & originalImage.size).corners.map { $0.applying(transform.cg) }
            let newBounds = newCorners.containingRect
//            print("   transform: \(transform)")
//            print("   new bounds: \(newBounds)")
            
//            assert(newBounds.minX == 0)
//            assert(newBounds.minY == 0)
            massert(newBounds.size == image.size)
            
//            print(" ")
        }
    
    }
    
    static func test2() {
        let originalImage = self.originalImage2
        let originalTexture = MetalHeapManager.shared.makeTexture(from: originalImage)!
        
        print("INITIAL")
        print("  image: \(originalImage.primaryColors)")
        print("texture: \(originalTexture.primaryColors)")
        
        print(" ")
        print(" ")
        print(" ")
        
        for orientation in all {
            let image = UIImage.init(cgImage: originalImage.cgImage!, scale: 1, orientation: orientation)
            
            let texture = originalTexture.reoriented(from: orientation)
            let transform = orientation.inverseTransform(for: originalImage.size)
            
            print("ORIENTATION: \(orientation)")
            
            for y in 0...1 {
                for x in 0...1 {
                    let a = CGPoint(x: x, y: y)
                    let b = a.applying(transform.cg)
                    print("    \(a) -> \(b)")
                }
            }
            
//            print("  transform: \(transform)")
//            print("  image: \(image.primaryColors)")
//            print("  texture: \(texture.primaryColors)")
            
            massert(image.primaryColors == texture.primaryColors)
            
//            print(" ")
        }
        
//        print(" ")
    }
    
    static func test3() {
        let originalImage = self.originalImage3
        let originalTexture = MetalHeapManager.shared.makeTexture(from: originalImage)!
        
//        print("INITIAL")
//        print("  image: \(originalImage.primaryColors)")
//        print("texture: \(originalTexture.primaryColors)")
//
//        print(" ")
//        print(" ")
//        print(" ")
        
        for orientation in all {
            let image = UIImage.init(cgImage: originalImage.cgImage!, scale: 1, orientation: orientation)
            
            let texture = originalTexture.reoriented(from: orientation)
            let transform = orientation.inverseTransform(for: originalImage.size)
            
//            print("ORIENTATION: \(orientation)")
            
            for y in 0...1 {
                for x in 0...1 {
                    let a = CGPoint(x: x, y: y)
                    let b = a.applying(transform.cg)
                    print("    \(a) -> \(b)")
                }
            }
            
//            print("  transform: \(transform)")
//            print("  image: \(image.primaryColors)")
//            print("  texture: \(texture.primaryColors)")
            
            massert(image.primaryColors == texture.primaryColors)
            
//            print(" ")
        }
        
//        print(" ")
    }
    
}
#endif

protocol OrientationTestable {
    
    var slowBytes: [UInt8] { get }
    
}

enum PrimaryColor: CustomDebugStringConvertible {
    case red, green, blue, black
    
    var debugDescription: String {
        switch self {
        case .red: return "red"
        case .green: return "green"
        case .blue: return "blue"
        case .black: return "black"
        }
    }
}

extension OrientationTestable {
    
    var primaryColors: [PrimaryColor] {
        var bytes = slowBytes
        var colors = [PrimaryColor]()
        
        while bytes.count >= 4  {
            let x = bytes.prefix(4)
            
            switch x {
            case [255,   0,   0, 255]: colors.append(.red)
            case [  0, 255,   0, 255]: colors.append(.green)
            case [  0,   0, 255, 255]: colors.append(.blue)
            case [  0,   0,   0, 255]: colors.append(.black)
            default:
                fatalError()
            }
            
            bytes.removeFirst(4)
        }
        
        return colors
    }
    
}

#if os(iOS)
extension UIImage: OrientationTestable {
    
    var slowBytes: [UInt8] {
        let context = DrawingContext(image: self)
        let buffer = UnsafeMutableBufferPointer<UInt8>.init(start: context.data, count: context.stride * context.height)
        return Array(buffer)
    }
    
}

extension MetalTexture: OrientationTestable {
    
    var slowBytes: [UInt8] {
        return uiImage.slowBytes
    }
    
}
#endif

//#if os(iOS)
extension ImageOrientation: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .up: return ".up"
        case .down: return ".down"
        case .left: return ".left"
        case .right: return ".right"
        case .upMirrored: return ".upMirrored"
        case .downMirrored: return ".downMirrored"
        case .leftMirrored: return ".leftMirrored"
        case .rightMirrored: return ".rightMirrored"
//        @unknown default: return "ImageOrientation.@unknown"
        }
    }
    
}
//#endif
