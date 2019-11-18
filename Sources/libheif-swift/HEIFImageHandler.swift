//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import libheif

public class HEIFImageHandler {
    
    public let handler: heif_image_handler_ptr
    
    public init(_ pointer: OpaquePointer) {
        handler = pointer
    }
    
}

