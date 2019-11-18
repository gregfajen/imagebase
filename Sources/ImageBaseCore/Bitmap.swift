//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

import Foundation

extension Pixel {
    
    static var size: Int { return MemoryLayout<Self>.size }
    
}


public class Bitmap<P: Pixel> {
    
    typealias U = P.U
    
    public let size: Size
    public let stride: Int
    
    public let data: UnsafeMutablePointer<P>
    
    public init(_ size: Size) {
        let stride = (P.size*size.width).lowestMultiple(of: 16)
        let bitmapSize = stride * size.height
        
        self.size = size
        self.stride = stride
        data = malloc(bitmapSize).assumingMemoryBound(to: P.self)
//        data = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: bitmapSize)
    }
    
    deinit {
        if let b = _rowsBuffer { b.deallocate() }
        free(data)
    }
    
    private var _rowsBuffer: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>>?
    public var rowsBuffer: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>> {
        if let buffer = _rowsBuffer { return buffer }
        
        let rows = UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>>.allocate(capacity: size.height)
        
        var ptr = UnsafeMutablePointer<UInt8>(OpaquePointer(data))!
        
        for i in 0..<size.height {
            rows[i] = ptr
            ptr = ptr.advanced(by: stride)
        }
        
        _rowsBuffer = rows
        return rows
    }
    
    public var rows: UnsafeMutablePointer<Optional<UnsafeMutablePointer<UInt8>>> {
        return .init(OpaquePointer(rowsBuffer.baseAddress!))
    }
    
    @inline(__always)
    func row(_ y: Int) -> UnsafeMutablePointer<P> {
        let base = UnsafeMutablePointer<UInt8>(OpaquePointer(data))!
        let ptr = base.advanced(by: stride * y)
        
        return .init(OpaquePointer(ptr))
    }
    
    @inline(__always)
    func sample(_ x: Int, _ y: Int) -> P {
        return row(y)[x]
    }
    
    @inline(__always)
    func set(_ x: Int, _ y: Int, v: P) {
        row(y)[x] = v
    }
    
    // I don't like this function because I think it does a lot of branching
    // in what's intended to be a tight loop
    func linearInterpolate(_ x: Float, _ y: Float) -> P {
        let width = size.width
        let height = size.height
        
        let fx = floor(x-0.5)
        let fy = floor(y-0.5)
        let tx = (x-0.5)-fx
        let ty = (y-0.5)-fy
        
        let x1 = Int(fx).clamp(min: 0, max: width-1)
        let y1 = Int(fy).clamp(min: 0, max: height-1)
        
        let x2 = x1 < (width-1) ? x1+1 : x1
        let y2 = y1 < (height-1) ? y1+1 : y1
        
        let x1y1 = sample(x1, y1)
        let x2y1 = sample(x2, y1)
        let x1y2 = sample(x1, y2)
        let x2y2 = sample(x2, y2)
        
        let xy1 = x1y1.mix(x2y1, tx)
        let xy2 = x1y2.mix(x2y2, tx)
        
        let p = xy1.mix(xy2, ty)
        return p
//
//        let v: P.W = sample(x1, y1).w
//            + sample(x1, y2).w
//            + sample(x2, y1).w
//            + sample(x2, y2).w
//
//        let v2 = v >> 2
//
//        return P(v2)
    }
    
    func halved() throws -> Bitmap<P> {
        let half = Size(size.width/2, size.height/2)
        guard half * 2 == size else { throw MiscError(/*"size not even"*/) }
        
        let target = Bitmap<P>(half)
        
        for y in 0..<half.height {
            for x in 0..<half.width {
                let x2 = x*2
                let y2 = y*2
                
                
                let p = P((sample(x2+0, y2+0).w +
                        sample(x2+1, y2+0).w +
                        sample(x2+0, y2+1).w +
                        sample(x2+1, y2+1).w) >> 2)
                
                target.set(x,y,v: p)
            }
        }
        
        return target
    }
    
    func resized(to new: Size) throws -> Bitmap<P> {
        let bitmap = Bitmap<P>(new)
        
        let ws = Float(size.width)  / Float(new.width)
        let hs = Float(size.height) / Float(new.height)
        
        for y in 0..<new.height {
            for x in 0..<new.width {
                let sx = (Float(x) + 0.5) * ws
                let sy = (Float(y) + 0.5) * hs
                
                let p = linearInterpolate(sx, sy)
                bitmap.set(x, y, v: p)
            }
        }
        
        return bitmap
    }
    
    public func map<Q: Pixel>(_ f: (P)->Q) -> Bitmap<Q> {
        let bitmap = Bitmap<Q>(size)
        
        for y in 0..<size.height {
            for x in 0..<size.width {
                let p = sample(x, y)
                let q = f(p)
                bitmap.set(x, y, v: q)
            }
        }
    
        return bitmap
    }
    
    public static func from<P>(_ source: Bitmap<P>, _ orientation: ImageOrientation = .up) -> Bitmap<P> {
        if orientation == .up { return source }
        
        let size = source.size.after(orientation)
        let target = Bitmap<P>(size)
        
        let transform = orientation.transform(for: source.size)
//        let stride = target.stride
        
        for x in 0..<size.width {
            for y in 0..<size.height {
                let (sx, sy) = transform * (x, y)
                let p = source.sample(sx, sy)
                target.set(x, y, v: p)
            }
        }
        
        return target
    }
    
}

extension Bitmap where P == RGBA<UInt8> {
    
    public func applying(_ matrix: DMatrix3x3) -> Bitmap<RGBA<UInt8>> {
        return map { p in
            let v = (1.0/255.0) * DVec3(p.r, p.g, p.b)
            let c =  (matrix * v)
            
            return RGBA<UInt8>(c.a, c.b, c.c, p.a)
        }
    }
    
}

public extension Int {
    
    func clamp(min: Int, max: Int) -> Int {
        if self < min { return min }
        if self > max { return max }
        return self
    }
    
    func lowestMultiple(of n: Int) -> Int {
        let (q, r) = quotientAndRemainder(dividingBy: n)
        return n * ((r == 0) ? q : q+1)
    }
    
    var lowestPowerOfTwo: Int {
        let me = UInt64(self)
        var result = UInt64(1)
        
        while result < me {
            result = result << 1
        }
        
        return Int(result)
    }
    
}

func * (l: IntAffineTransform, r: (Int,Int)) -> (Int,Int) {
    let t = l
    let p = r
    let x = p.0 * Int(t.a) + p.1 * Int(t.b);
    let y = p.0 * Int(t.c) + p.1 * Int(t.d);
    
    return (x + Int(t.x), y + Int(t.y))
}
