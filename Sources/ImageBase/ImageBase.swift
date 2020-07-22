//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation
@exported import ImageBaseCore

@exported import libpng_swift
@exported import libheif_swift
@exported import libjpeg_swift
@exported import libwebp_swift

public extension MimeType {
    
    var ext: String {
        switch self {
            case .gif: return "gif"
            case .heif: return "heic"
            case .jpeg: return "jpg"
            case .png: return "png"
            case .mp4: return "mp4"
            case .webp: return "webp"
        }
    }
    
    func encode(image: Image) throws -> Data {
        switch self {
            case .png: return try PNG.encode(image: image)
            case .heif: return try HEIF.encode(image: image)
            case .jpeg: return try JPEG.encode(image: image)
            case .webp: return try WEBP.encode(image: image)
            default: throw MiscError()
        }
    }
    
}
