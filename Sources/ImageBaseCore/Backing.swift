//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation

public enum ImageBacking<U: Ub> {
    
    case G(Bitmap<Mono<U>>)
    case GA(Bitmap<MonoAlpha<U>>)
    case RGB(Bitmap<RGB<U>>)
    case RGBA(Bitmap<RGBA<U>>)
    case YCbCr(Bitmap<Mono<U>>, Bitmap<Mono<U>>, Bitmap<Mono<U>>)
    case YCbCrA(Bitmap<Mono<U>>, Bitmap<Mono<U>>, Bitmap<Mono<U>>, Bitmap<Mono<U>>)
    
    var size: Size {
        switch self {
            case .G(let i): return i.size
            case .GA(let i): return i.size
            case .RGB(let i): return i.size
            case .RGBA(let i): return i.size
            case .YCbCr(let Y, _, _): return Y.size
            case .YCbCrA(let Y, _, _, _): return Y.size
        }
    }
    
    func halved() throws -> ImageBacking<U> {
        switch self {
            case .G(let b): return .G(try b.halved())
            case .GA(let b): return .GA(try b.halved())
            case .RGB(let b): return .RGB(try b.halved())
            case .RGBA(let b): return .RGBA(try b.halved())
            case .YCbCr(let y, let cb, let cr):
                return .YCbCr(try y.halved(), try cb.halved(), try cr.halved())
            case .YCbCrA(let y, let cb, let cr, let a):
                return .YCbCrA(try y.halved(), try cb.halved(), try cr.halved(), try a.halved())
        }
    }
    
}
