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
        
        DGifSlurp(file)
        if file?.pointee.Error != D_GIF_SUCCEEDED {
            throw MiscError()
        }
        
        let width = file!.pointee.SWidth
        let height = file!.pointee.SHeight
        let count = file!.pointee.ImageCount
        print("Size: \(width) x \(height)")
        print("Count: \(count)")
        
        fatalError()
    }
    
}
