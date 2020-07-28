//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

import Foundation

public protocol ImageEncoder {
    
    static func encode(image: Image, quality: Int) throws -> Data
    
}

public protocol ImageDecoder {
    
    static func decode(path: String) throws -> Image
    static func decode(data: Data) throws -> Image
//    static func decode(file: PseudoFile) throws -> Image
    static func decode(fp: UnsafeMutablePointer<FILE>) throws -> Image
    
}

public protocol DataBasedDecoder: ImageDecoder {
    
}

public extension DataBasedDecoder {
    
    static func decode(path: String) throws -> Image {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try decode(data: data)
    }
    
//    static func decode(file: PseudoFile) throws -> Image {
//        let data = Data(bytesNoCopy: file.ptr, count: file.size, deallocator: .none)
//        return try decode(data: data)
//    }
    
    static func decode(fp: UnsafeMutablePointer<FILE>) throws -> Image {
        let data = Data(fp: fp)
        return try decode(data: data)
    }
    
}

public protocol FileBasedDecoder: ImageDecoder {
    
}

public extension FileBasedDecoder {
    
    
    static func decode(path: String) throws -> Image {
        guard let fp = fopen(path, "rb") else { throw MiscError() }
        let image = try decode(fp: fp)
        fclose(fp)
        return image
    }
    
    static func decode(data: Data) throws -> Image {
        guard let fp = tmpfile() else { throw MiscError() }
        fwrite(data.address, 1, data.count, fp)
        fseek(fp, 0, SEEK_SET)
        
        return try decode(fp: fp)
    }
    
//    static func decode(file: PseudoFile) throws -> Image {
//        guard let fp = fdopen(file.fd, "rb") else { throw MiscError() }
//        let bitmap = try decode(fp: fp)
//        fclose(fp)
//        return bitmap
//    }
    
}

extension Data {
    
    public init(fp: UnsafeMutablePointer<FILE>) {
        let bufferSize = 1024
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: bufferSize)
        
        let pointer = UnsafeMutableRawPointer(OpaquePointer(buffer.baseAddress))
        
        var data = Data()
        
        var keepGoing = true
        while keepGoing {
            let got = fread(pointer, 1, bufferSize, fp)
            data.append(buffer.baseAddress!, count: got)
            
            if got < bufferSize { keepGoing = false }
        }
        
        self = data
    }
    
}
