//
//  gif.swift
//  App
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import ImageBaseCore
import giflib

public struct GIF: PathBasedDecoder {
    
    public static func decode(path: String) throws -> Image {
        var error: Int32 = 0
        let file = DGifOpenFileName(path, &error)
        if error != D_GIF_SUCCEEDED {
            throw MiscError()
        }
        
        guard DGifSlurp(file) == GIF_OK else {
            throw MiscError()
        }
        
        if file?.pointee.Error != D_GIF_SUCCEEDED {
            throw MiscError()
        }
        
        guard let filetype = file?.pointee else {
            throw MiscError()
        }
        
        
        
        
        let width = filetype.SWidth
        let height = filetype.SHeight
        let count = filetype.ImageCount
        
        print("Size: \(width) x \(height)")
        print("Count: \(count)")
        
        let first = filetype.SavedImages.pointee /*else {
            throw MiscError()
        }*/
        
        
//        first
        
        fatalError()
    }
    
}
