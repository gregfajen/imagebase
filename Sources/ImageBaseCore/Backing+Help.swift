//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation

extension ImageBacking {
    
    init<P: Pixel>(_ bitmap: Bitmap<P>) {
        switch P.pixelType {
            case .y: self = .G(bitmap as! Bitmap<Mono<U>>)
            case .ya: self = .GA(bitmap as! Bitmap<MonoAlpha<U>>)
            case .rgb: self = .RGB(bitmap as! Bitmap<RGB<U>>)
            case .rgba: self = .RGBA(bitmap as! Bitmap<RGBA<U>>)
        }
    }
    
}
