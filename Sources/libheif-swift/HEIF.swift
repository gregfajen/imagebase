//
//  File.swift
//
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation
import ImageBaseCore
import libheif

public struct HEIF: ImageEncoder, DataBasedDecoder {

    static func image(for backing: ImageBacking<UInt8>,
                      _ profile: ColorProfile?) throws -> HEIFImage {
        
        switch backing {
            case .RGB, .RGBA: throw MiscError()
            
            case .GA(let GA):
                return try HEIFImage(GA: GA, profile)
            
            case .G(let Y):
                return try HEIFImage(Y: Y, A: nil, profile)
            //            case .GA(let Y, let A):
            //                return try HEIFImage(Y: Y, A: A, profile)
            
            case .YCbCr(let Y, let Cb, let Cr):
                return try HEIFImage(Y: Y, Cb: Cb, Cr: Cr, A: nil, profile)
            case .YCbCrA(let Y, let Cb, let Cr, let A):
                return try HEIFImage(Y: Y, Cb: Cb, Cr: Cr, A: A, profile)
        }
    }
    
    public static func encode(image: Image) throws -> Data {
        let backing = try image.backing.asYCbCr().as420()
        let image = try self.image(for: backing, image.profile)
        
        //        let image = try HEIFImage(Y: y, Cb: cb, Cr: cr, image.profile)
        
        
        let data = try heif_write(image: image)
        return data
    }
    
    public static func decode(data: Data) throws -> Image {
        let heif = try HEIFImage.reading(data)
        return heif.image
    }
    
}


