//
//  File.swift
//
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation

extension ImageBacking {
    
    func removingColor() -> ImageBacking {
        switch self {
            case .G, .GA: return self
            
            case .RGB(let bitmap):
                return .G(bitmap.map { (source: RGB<U>) -> Mono<U> in
                    return .init(convertRGBtoY(R: source.r, G: source.g, B: source.b))
                })
            
            case .RGBA(let bitmap):
                return .GA(bitmap.map { (source: RGBA<U>) -> MonoAlpha<U> in
                    return .init(convertRGBtoY(R: source.r, G: source.g, B: source.b), source.a)
                })
            
            case .YCbCr(let Y, _, _):
                return .G(Y)
            
            case .YCbCrA(let Y, _, _, let A):
                let result = Y.zip(with: A) { (y: Mono<U>, a: Mono<U>) -> MonoAlpha<U> in
                    return .init(y.v, a.v)
                }
                
                return ImageBacking.GA(result)
        }
    }
    
    func addingColor() -> ImageBacking {
        switch self {
            case .G(let bitmap):
                return .RGB(bitmap.map { (source: Mono<U>) -> RGB<U> in
                    return .init(source.v, source.v, source.v)
                })
            
            case .GA(let bitmap):
                return .RGBA(bitmap.map { (source: MonoAlpha<U>) -> RGBA<U> in
                    return .init(source.v, source.v, source.v, source.a)
                })
            
            case .RGB, .RGBA, .YCbCr, .YCbCrA:
                return self
        }
    }
    
    var hasColor: Bool {
        switch self {
            case .G, .GA: return false
            default: return true
        }
    }
    
    func checkIfNeedsColor() -> Bool {
        switch self {
            case .G, .GA: return false
            
            
            case .RGB(let bitmap):
                for y in 0..<bitmap.size.height {
                    for x in 0..<bitmap.size.width {
                        let p = bitmap.sample(x, y)
                        
                        let d1 = abs(Int(p.r)-Int(p.g))>2
                        let d2 = abs(Int(p.g)-Int(p.b))>2
                        let d3 = abs(Int(p.r)-Int(p.b))>2
                        
                        if d1 || d2 || d3 { return true }
                    }
                }
                
                return false
            
            case .RGBA(let bitmap):
                for y in 0..<bitmap.size.height {
                    for x in 0..<bitmap.size.width {
                        let p = bitmap.sample(x, y)
                        
                        let d1 = abs(Int(p.r)-Int(p.g))>2
                        let d2 = abs(Int(p.g)-Int(p.b))>2
                        let d3 = abs(Int(p.r)-Int(p.b))>2
                        
                        if d1 || d2 || d3 { return true }
                    }
                }
                
                return false
            
            case .YCbCr(_, let Cb, let Cr):
                for y in 0..<Cb.size.height {
                    for x in 0..<Cb.size.width {
                        let cb = Cb.sample(x, y).v
                        let cr = Cr.sample(x, y).v
                        
                        if cb.clamp(min: 126,max: 129) == cb {
                            if cr.clamp(min: 126,max: 129) == cr {
                                continue
                            }
                        }
                        
                        return true
                    }
                }
                
                return false
            
            case .YCbCrA(_, let Cb, let Cr, _):
                for y in 0..<Cb.size.height {
                    for x in 0..<Cb.size.width {
                        let cb = Cb.sample(x, y).v
                        let cr = Cr.sample(x, y).v
                        
                        if cb.clamp(min: 126,max: 129) == cb {
                            if cr.clamp(min: 126,max: 129) == cr {
                                continue
                            }
                        }
                        
                        return true
                    }
                }
                
                return false
        }
    }
    
    func convertRGBtoY<U: Ub>(R: U, G: U, B: U) -> (U) {
        let R = Int(R)
        let G = Int(G)
        let B = Int(B)
        
        let Y = (77 * R + 150 * G + 29 * B) >> 8
        
        return (U(Y.clamp(min: 0, max: 255)))
    }
    
}
