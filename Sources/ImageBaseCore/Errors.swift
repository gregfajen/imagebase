//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

import Foundation

public struct MiscError: Error {
    
    let message: String
    
    public init(_ message: String = "unknown error") {
        self.message = message
    }
    
}

public struct GenericError<T>: Error {
    let message: String
    public init(_ message: String = "") { self.message = message }
}
