//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import libheif

public class HEIFContext {
    
    let context: heif_context_ptr
    
    public init() {
        context = heif_context_alloc()
    }
    
    deinit {
        heif_context_free(context)
    }
    
}
