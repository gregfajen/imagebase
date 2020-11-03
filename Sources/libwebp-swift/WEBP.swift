//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/26/19.
//

import Foundation
import ImageBaseCore
import libwebp

typealias WEBPError = GenericError<WEBP>

public struct WEBP: ImageEncoder {
    
    public static func encodeRGB(_ bitmap: Bitmap<RGB<UInt8>>, quality: Int) throws -> Data {
        var output = UnsafeMutablePointer<UInt8>(bitPattern: 0)
        
        let inputO = OpaquePointer(bitmap.data)
        let input = UnsafePointer<UInt8>(inputO)
        
        let size = WebPEncodeRGB(input,
                                 Int32(bitmap.size.width),
                                 Int32(bitmap.size.height),
                                 Int32(bitmap.stride),
                                 Float(quality),
                                 &output)
        
        defer { WebPFree(output) }
        
        if size > 0 {
            return Data(bytes: output!, count: size)
        } else {
            throw MiscError()
        }
    }
    
    public static func encodeRGBA(_ bitmap: Bitmap<RGBA<UInt8>>, quality: Int) throws -> Data {
        var output = UnsafeMutablePointer<UInt8>(bitPattern: 0)
        
        let inputO = OpaquePointer(bitmap.data)
        let input = UnsafePointer<UInt8>(inputO)
        
        let size = WebPEncodeRGBA(input,
                                  Int32(bitmap.size.width),
                                  Int32(bitmap.size.height),
                                  Int32(bitmap.stride),
                                  Float(quality),
                                  &output)
        
        defer { WebPFree(output) }
        
        if size > 0 {
            return Data(bytes: output!, count: size)
        } else {
            throw MiscError()
        }
    }
    
    public static func encode(image: Image, quality: Int) throws -> Data {
        switch image.addingColor().backing {
            case .RGB(let bitmap): return try encodeRGB(bitmap, quality: quality)
            case .RGBA(let bitmap): return try encodeRGBA(bitmap, quality: quality)
            case .G, .GA, .YCbCr, .YCbCrA: throw MiscError()
        }
    }
    
}

extension WEBP: DataBasedDecoder {
    
    public static func decode(data: Data) throws -> Image {
        var pointer: UnsafePointer<UInt8>!
        data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Void in
            pointer = rawBufferPointer.bindMemory(to: UInt8.self).baseAddress
        }
        
        var width: Int32 = 0
        var height: Int32 = 0
        guard WebPGetInfo(pointer, data.count, &width, &height) == 1 else {
            throw WEBPError("WebPGetInfo failed")
        }
        
        var config = WebPDecoderConfig()
        guard WebPInitDecoderConfig(&config) == 1 else {
            throw WEBPError("WebPInitDecoderConfig failed")
        }
        
        let bitmap = Bitmap<RGBA<UInt8>>(Size(width, height))
        let bitmapCount = bitmap.stride * bitmap.size.height
        bitmap.data.withMemoryRebound(to: UInt8.self, capacity: bitmapCount) { pointer -> Void in
            config.output.colorspace = MODE_RGBA
            config.output.u.RGBA.rgba = pointer
            config.output.u.RGBA.stride = Int32(bitmap.stride)
            config.output.u.RGBA.size = bitmapCount
            config.output.is_external_memory = 1
        }
        
        let status = WebPDecode(pointer, data.count, &config)
        guard status == VP8_STATUS_OK else {
            throw WEBPError("WebPDecode failed with status \(status.rawValue)")
        }
        
        let image = Image(bitmap)
        return image
    }
    
}
