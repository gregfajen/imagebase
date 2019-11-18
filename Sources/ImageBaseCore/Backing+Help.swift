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
            case .y: fatalError()
            case .ya: fatalError()
            case .rgb: self = .RGB(bitmap as! Bitmap<RGB<U>>)
            case .rgba: self = .RGBA(bitmap as! Bitmap<RGBA<U>>)
        }
    }
    
}
