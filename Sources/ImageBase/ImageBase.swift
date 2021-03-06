//
//  File.swift
//
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation
@_exported import ImageBaseCore

@_exported import libpng_swift
@_exported import libheif_swift
@_exported import libjpeg_swift
@_exported import libwebp_swift
@_exported import giflib_swift

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
    
    func encode(image: Image, quality: Int = 65) throws -> Data {
        switch self {
            case .png: return try PNG.encode(image: image, quality: quality)
            case .heif: return try HEIF.encode(image: image, quality: quality)
            case .jpeg: return try JPEG.encode(image: image, quality: quality)
            case .webp: return try WEBP.encode(image: image, quality: quality)
            default: throw MiscError()
        }
    }
    
    func decode(data: Data) throws -> Image {
        switch self {
            case .png: return try PNG.decode(data: data)
            case .heif: return try HEIF.decode(data: data)
            case .jpeg: return try JPEG.decode(data: data)
            case .webp: return try WEBP.decode(data: data)
//            case .gif: return try GIF.decode(data: data)
            default: throw MiscError()
        }
    }
    
}
