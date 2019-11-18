//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation

public struct ColorProfile {
    
    public let data: Data
    
    public init(_ data: Data) {
        self.data = data
    }
    
    public var pointer: UnsafeRawPointer {
        return data.address
    }
    
    public var length: Int {
        return data.count
    }
    
}
