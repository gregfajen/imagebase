//
//  ImageType.swift
//  Image
//
//  Created by Greg Fajen on 11/14/19.
//

import Foundation


public enum MimeType: String {
    case heif = "image/heic"
    case jpeg = "image/jpeg"
    case png  = "image/png"
    case gif  = "image/gif"
    case mp4  = "video/mp4"
    case webp = "image/webp"
}

public extension Data {
    
    var address: UnsafeRawPointer {
        return (self as NSData).bytes
    }
    
    var mimeType: MimeType? {
        guard count > 0 else {
            print("TRIED TO GET MIMETYPE FOR EMPTY DATA?")
            return nil
        }
        
        let byte = address.assumingMemoryBound(to: UInt8.self).pointee
        
        switch byte {
            case 0x89: return .png
            case 0xff: return .jpeg
            case 0x47: return .gif
            case 0x00: return .mp4
            case 102: return .heif
            case 0x52: return .webp
            default:
                let hex = String.init(byte, radix: 16, uppercase: true)
                print("NO KNOWN MIMETYPE FOR DATA STARTING WITH \(hex)")
                
//                #if os(iOS)
//                if let image = UIImage(data: self) {
//                    print("image: \(image)")
//                } else {
//                    print("invalid image!")
//                }
//                #endif
                
                return nil
        }
    }
    
}
