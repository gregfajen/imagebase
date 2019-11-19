//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation
import ImageBaseCore

import libpng_swift
import libheif_swift
import libjpeg_swift

public extension MimeType {
    
    var ext: String {
        switch self {
            case .gif: return "gif"
            case .heif: return "heif"
            case .jpeg: return "jpg"
            case .png: return "png"
            case .mp4: return "mp4"
        }
    }
    
    func encode(image: Image) throws -> Data {
        switch self {
            case .png: return try PNG.encode(image: image)
            case .heif: return try HEIF.encode(image: image)
            case .jpeg: return try JPEG.encode(image: image)
            default: throw MiscError()
        }
    }
    
}
