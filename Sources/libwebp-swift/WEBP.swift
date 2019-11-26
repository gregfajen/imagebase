//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/26/19.
//

import Foundation
import ImageBaseCore
import libwebp

public struct WEBP: ImageEncoder {
    
    static var quality: Float { return 60 }
    
    public static func encodeRGB(_ bitmap: Bitmap<RGB<UInt8>>) throws -> Data {
        var output = UnsafeMutablePointer<UInt8>(bitPattern: 0)
        
        let inputO = OpaquePointer(bitmap.data)
        let input = UnsafePointer<UInt8>(inputO)
        
        let size = WebPEncodeRGB(input,
                                 Int32(bitmap.size.width),
                                 Int32(bitmap.size.height),
                                 Int32(bitmap.stride),
                                 quality,
                                 &output)
        
        defer { WebPFree(output) }
        
        if size > 0 {
            return Data(bytes: output!, count: size)
        } else {
            throw MiscError()
        }
    }
    
    public static func encodeRGBA(_ bitmap: Bitmap<RGBA<UInt8>>) throws -> Data {
        var output = UnsafeMutablePointer<UInt8>(bitPattern: 0)
        
        let inputO = OpaquePointer(bitmap.data)
        let input = UnsafePointer<UInt8>(inputO)
        
        let size = WebPEncodeRGBA(input,
                                  Int32(bitmap.size.width),
                                  Int32(bitmap.size.height),
                                  Int32(bitmap.stride),
                                  quality,
                                  &output)
        
        defer { WebPFree(output) }
        
        if size > 0 {
            return Data(bytes: output!, count: size)
        } else {
            throw MiscError()
        }
    }
    
    public static func encode(image: Image) throws -> Data {
        switch image.addingColor().backing {
            case .RGB(let bitmap): return try encodeRGB(bitmap)
            case .RGBA(let bitmap): return try encodeRGBA(bitmap)
            case .G, .GA, .YCbCr, .YCbCrA: throw MiscError()
        }
    }
    
}
