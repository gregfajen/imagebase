//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation

public extension ImageBacking {
    
    var is420: Bool {
        switch self {
            case .YCbCr(let Y, let Cb, _):
                return Cb.size.width < Y.size.width
            default: return false
        }
    }
    
    func asYCbCr() -> ImageBacking<U> {
        if hasAlpha {
            return asYCbCrA()
        }
        
        let bitmap: Bitmap<RGB<UInt8>>
        switch self {
            
            case .GA, .RGBA, .YCbCrA: fatalError()
            
            case .G: return self
            case .RGB(let b): bitmap = b as! Bitmap<RGB<UInt8>>
            case .YCbCr: return self
        }
        
        let size = bitmap.size
        
        let Y = Bitmap<Mono<UInt8>>(size)
        let Cb = Bitmap<Mono<UInt8>>(size)
        let Cr = Bitmap<Mono<UInt8>>(size)
        
        for y in 0..<size.height {
            for x in 0..<size.width {
                let rgba = bitmap.sample(x, y)
                
                let (_Y, _Cb, _Cr) = convertRGBtoYCbCr(R: rgba.r, G: rgba.g, B: rgba.b)
                
                Y.set(x, y, v: .init(_Y))
                Cb.set(x, y, v: .init(_Cb))
                Cr.set(x, y, v: .init(_Cr))
            }
        }
        
        return .YCbCr(Y as! Bitmap<Mono<U>>,
                      Cb as! Bitmap<Mono<U>>,
                      Cr as! Bitmap<Mono<U>>)
    }
    
    func asYCbCrA() -> ImageBacking<U> {
        let bitmap: Bitmap<RGBA<UInt8>>
        switch self {
            case .RGB: fatalError()
            case .RGBA(let b): bitmap = b as! Bitmap<RGBA<UInt8>>
            default: return self
        }
        
        let size = bitmap.size
        
        let Y = Bitmap<Mono<UInt8>>(size)
        let Cb = Bitmap<Mono<UInt8>>(size)
        let Cr = Bitmap<Mono<UInt8>>(size)
        
        for y in 0..<size.height {
            for x in 0..<size.width {
                let rgba = bitmap.sample(x, y)
                
                let (_Y, _Cb, _Cr) = convertRGBtoYCbCr(R: rgba.r, G: rgba.g, B: rgba.b)
                
                Y.set(x, y, v: .init(_Y))
                Cb.set(x, y, v: .init(_Cb))
                Cr.set(x, y, v: .init(_Cr))
            }
        }
        
        return .YCbCr(Y as! Bitmap<Mono<U>>,
                      Cb as! Bitmap<Mono<U>>,
                      Cr as! Bitmap<Mono<U>>)
    }
    
    func as420() throws -> ImageBacking<U> {
        let YCbCr = asYCbCr()
        guard let (y, cb, cr, a) = YCbCr.y_cb_cr else { return self }
        
        let sY = y.size
        let scb = cb.size
        let scr = cr.size
        
        guard scb == scr else { throw MiscError() }
        
        if scr == sY {
            let cb2 = try cb.halved()
            let cr2 = try cr.halved()
            if let a = a {
                return .YCbCrA(y, cb2, cr2, a)
            } else {
                return .YCbCr(y, cb2, cr2)
            }
        } else if scr * 2 == sY {
            return self
        } else {
            throw MiscError()
        }
    }
    
    var y_cb_cr: (Bitmap<Mono<U>>, Bitmap<Mono<U>>, Bitmap<Mono<U>>, Bitmap<Mono<U>>?)? {
        switch self {
            case .YCbCr(let y, let cb, let cr): return (y, cb, cr, nil)
            case .YCbCrA(let y, let cb, let cr, let a): return (y, cb, cr, a)
            default: return nil
        }
    }
    
}

func * (l: Size, r: Int) -> Size {
    return Size(l.width * r, l.height * r)
}
