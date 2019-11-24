//
//  File.swift
//
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import libheif

public class HEIFEncoder {
    
    let encoder: heif_encoder_ptr
    
    public init() throws {
        let format = heif_compression_HEVC
        var result: OpaquePointer?
        let error = heif_context_get_encoder_for_format(nil, format, &result)
        if error.exists { throw error }
        print("error: \(error.code) \(error.subcode)")
        
        if let encoder = result {
            self.encoder = encoder
        } else {
            fatalError()
        }
    }
    
    deinit {
        heif_encoder_release(encoder)
    }
    
    public var lossyQuality: Int = 100 {
        didSet {
            heif_encoder_set_lossy_quality(encoder, Int32(lossyQuality))
        }
    }
    
}

