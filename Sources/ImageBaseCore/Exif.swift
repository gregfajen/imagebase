//
//  Exif.swift
//  Exif
//
//  Created by Greg Fajen on 11/13/19.
//  Copyright © 2019 greg. All rights reserved.
//

import Foundation

struct DataStreamError: Error {
    
}

class DataStream {
    
    let data: Data
    var cursor = 0
    
    convenience init(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        self.init(data)
    }
    
    convenience init(_ bytes: [UInt8]) {
        let data = Data(bytes: bytes, count: bytes.count)
        self.init(data)
    }
    
    init(_ data: Data, cursor: Int = 0) {
        self.data = data
        self.cursor = cursor
    }
    
    func copy() -> DataStream { return DataStream(data, cursor: cursor) }
    func renewed() -> DataStream { return DataStream(data) }
    func withCursor(_ cursor: Int) -> DataStream { return DataStream(data, cursor: cursor) }
    
    private func subdata(for range: Range<Int>) -> [UInt8] {
        return Array(data.subdata(in: range))
    }
    
    func offset(_ bytes: Int) {
        cursor += bytes
    }
    
    func get(_ bytes: Int) throws -> [UInt8] {
        if bytes > remaining { throw DataStreamError() }
        let result = subdata(for: cursor..<(cursor+bytes))
        cursor += bytes
        
        return result
    }
    
    var remaining: Int { return data.count - cursor }
    
    var hexString: String {
        return (try? hex(copy().get(remaining))) ?? ""
    }
    
}

func hex(_ bytes: [UInt8]) -> String {
    return bytes.map { String(format: "%02x", $0) } .joined()
}

func int(_ bytes: [UInt8]) -> Int {
    
    bytes.reduce(into: 0) { $0 = ($0 << 8) + Int($1) }
    
}

func parseExif(_ bytes: [UInt8]) throws -> ImageOrientation? {
    var bytes = bytes
    while let b = bytes.first, b == 0 {
        bytes.removeFirst()
    }
    
    return try parseExif(DataStream(bytes))
}

struct IFDEntry {
    
    let stream: DataStream
    
    let tag: [UInt8]
    let type: IFDType
    let count: Int
    let offset: DataStream
    
    init(_ stream: DataStream) throws {
        tag = try stream.get(2)
        type = try IFDType(stream.get(2))!
        count = try int(stream.get(4))
        offset = stream.copy()
        
        self.stream = stream.withCursor(int(try stream.get(4)))
    }
    
    var valueFitsInOffsetField: Bool {
        return count * type.size < 4
    }
    
    func offsetAsInt(of bytes: Int) -> Int {
        guard let b = try? offset.copy().get(bytes) else { return 0 }
        return int(b)
    }
    
    var value: Any? {
        guard count == 1 else { return nil }
        switch type {
            case .byte: return offsetAsInt(of: 1)
            case .short: return offsetAsInt(of: 2)
            case .long: return offsetAsInt(of: 4)
            case .ascii: return nil
            case .rational:
                guard let nb = try? stream.get(4) else { return nil }
                guard let nd = try? stream.get(4) else { return nil }
                
                let n = int(nb)
                let d = int(nd)
                return Double(n) / Double(d)
        }
    }
    
}

enum IFDType: Int {
    case byte = 1
    case ascii = 2
    case short = 3
    case long = 4
    case rational = 5
    
    init?(_ bytes: [UInt8]) {
        self.init(rawValue: int(bytes))
    }
    
    var size: Int {
        switch self {
            case .byte: return 1
            case .ascii: return 1
            case .short: return 2
            case .long: return 4
            case .rational: return 8
        }
    }
    
}

func parseIFD(_ stream: DataStream) throws -> ImageOrientation? {
//    print("IFD")
//    print("\(stream.hexString)")
    
    let fc = try stream.get(2)
    let fieldCount = int(fc)
    
//    print("\(hex(fc))")
//    print("count: \(fieldCount)")
    
    let fields = try (0..<fieldCount).map { _ in
        return try IFDEntry(stream)
//        return IFDEntry(tag: int(stream.get(2)),
//                        type: IFDType(stream.get(2))!,
//                        count: int(stream.get(4)),
//                        offset: int(stream.get(4)))
    }
    
    for field in fields {
        print("\(field)")
        if field.tag == [0x01, 0x12] {
            if let value = field.value as? Int {
                return ImageOrientation(rawValue: UInt8(value))
            }
        }
        
//        print("    tag: 0x\(hex(field.tag))")
//        print("    fits: \(field.valueFitsInOffsetField)")
//        print("    value: \(field.value)")
//        print("    off: \(field.offset)")
    }
    
    guard let n = try? stream.get(4) else { return nil }
    let next = int(n)
    if next == 0 { return nil }
    
//    print("next: \(next)")
    return try parseIFD(stream.withCursor(next))
    
}

func parseExif(_ stream: DataStream) throws -> ImageOrientation? {
//    print("EXIF")
//    print("\(stream.hexString)")
    
    let MM = try stream.get(2)
    guard MM[0] == 0x4d, MM[1] == 0x4d else { return nil }
    
    let fortyTwo = int(try stream.get(2))
    guard fortyTwo == 42 else { return nil }
    
    let ifdOffset = int(try stream.get(4))
//    print("ifdOffset: \(ifdOffset)")
    return try parseIFD(stream.withCursor(ifdOffset))
}

// hilariously inefficient, optimize soon
public func getOrientation(from data: Data) -> ImageOrientation? {
    do {
//    let stream = DataStream("/Users/greg/Desktop/test.jpeg")
        let stream = DataStream(data)
    
    let header = try stream.get(2)
    guard header == [0xff, 0xd8] else { return nil }
    
//    print("header: \(hex(header))")
    
    while stream.remaining > 2 {
//        print("")
        _ = try stream.get(2)
//        print("identifier: \(hex(identifier))")
        
        let sizeBytes = try stream.get(2)
        let size = int(sizeBytes)
//        print("\(sizeBytes)")
//        print("size: \(size)")
        
        let chunk = try stream.get(size-2)
//        print("got chunk")
//
//        print("\(hex(chunk))")
//        print(" ")
        if chunk.prefix(4) == [0x45, 0x78, 0x69, 0x66] {
//            let exif =
            if let orientation = try parseExif(Array(chunk.dropFirst(4))) {
                return orientation
            }
        }
        
//        let string = NSString(bytes: chunk, length: chunk.count, encoding: String.Encoding.ascii.rawValue)! as String
//        let string = String(bytes: chunk, encoding: .nonLossyASCII)
//        print("\(string)")
//
//        print("remaining: \(stream.remaining)")
//        print("")
    }
    
//    assert(stream.remaining == 2)
    
    let footer = try stream.get(2)
//    print("footer: \(hex(footer))")
        return nil
    } catch _ {
        return nil
    }
    
}
