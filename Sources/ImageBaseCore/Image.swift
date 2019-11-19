//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation

public class Image {
    
    public let backing: ImageBacking<UInt8>
    public var profile: ColorProfile?
    
    public var size: Size { return backing.size }
    
    public init<P>(_ bitmap: Bitmap<P>,
                _ profile: ColorProfile? = nil) {
        self.backing = .init(bitmap)
        self.profile = profile
    }
    
    init(_ backing: ImageBacking<UInt8>,
         _ profile: ColorProfile? = nil) {
        self.backing = backing
        self.profile = profile
    }
    
    public func halved() throws -> Image {
        return Image(try backing.halved(), profile)
    }
    
    public func resized(to new: Size) throws -> Image {
        return Image(try backing.resized(to: new), profile)
    }
    
    public func checkNeedsAlpha() -> Bool {
        return backing.checkIfNeedsAlpha()
    }
    
    public func removingAlpha() -> Image {
        return Image(backing.removingAlpha(), profile)
    }
    
    public func checkNeedsColor() -> Bool {
        return backing.checkIfNeedsColor()
    }
    
    public func removingColor() -> Image {
        return Image(backing.removingColor(), profile)
    }
    
}
