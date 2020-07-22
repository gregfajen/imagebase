//
//  File.swift
//
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import libheif
import ImageBaseCore

public class HEIFImage {
    
    let ptr: heif_image_ptr
    
    deinit {
        heif_image_release(ptr)
    }
    
    init(_ image: heif_image_ptr) {
        self.ptr = image
    }
    
    public static func reading(_ data: Data) throws -> HEIFImage {
        try heif_read(data: data)
    }
    
    convenience init(GA: Bitmap<MonoAlpha<UInt8>>, _ profile: ColorProfile?) throws {
        let (Y, A) = GA.unzip { (ga: MonoAlpha<UInt8>) -> (Mono<UInt8>, Mono<UInt8>) in
            return (.init(ga.v), .init(ga.a))
        }
        
        try self.init(Y: Y, A: A, profile)
    }
    
    public init(Y: Bitmap<Mono<UInt8>>,
                A:  Bitmap<Mono<UInt8>>?,
                _ profile: ColorProfile?) throws {
        var result: OpaquePointer?
        
        let size = Y.size
        let error = heif_image_create(Int32(size.width),
                                      Int32(size.height),
                                      heif_colorspace_monochrome,
                                      heif_chroma_monochrome,
                                      &result)
        if error.exists { throw error }
        
        guard let image = result else { throw MiscError() }
        self.ptr = image
        
        try addPlane(heif_channel_Y, bitmap: Y)
        
        if let A = A {
            try addPlane(heif_channel_Alpha, bitmap: A)
        }
        
        if let profile = profile {
            try setProfile(profile)
        }
    }
    
    public init(Y: Bitmap<Mono<UInt8>>,
                Cb: Bitmap<Mono<UInt8>>,
                Cr: Bitmap<Mono<UInt8>>,
                A:  Bitmap<Mono<UInt8>>?,
                _ profile: ColorProfile?) throws {
        var result: OpaquePointer?
        
        let size = Y.size
        let error = heif_image_create(Int32(size.width),
                                      Int32(size.height),
                                      heif_colorspace_YCbCr,
                                      heif_chroma_420,
                                      &result)
        if error.exists { throw error }
        
        guard let image = result else { throw MiscError() }
        self.ptr = image
        
        try addPlane(heif_channel_Y, bitmap: Y)
        try addPlane(heif_channel_Cb, bitmap: Cb)
        try addPlane(heif_channel_Cr, bitmap: Cr)
        
        if let A = A {
            try addPlane(heif_channel_Alpha, bitmap: A)
        }
        
        if let profile = profile {
            try setProfile(profile)
        }
    }
    
    func addPlane(_ channel: heif_channel,
                  bitmap: Bitmap<Mono<UInt8>>) throws {
        let size = bitmap.size
        let error = heif_image_add_plane(ptr,
                                         channel,
                                         Int32(size.width),
                                         Int32(size.height),
                                         8)
        if error.exists { throw error }
        
        var ts_: Int32 = 0
        var target: UnsafeMutablePointer<UInt8> = heif_image_get_plane(ptr, channel, &ts_)
        let ts: Int = Int(ts_)
        
        let ss: Int = bitmap.stride
        var source: UnsafeMutablePointer<UInt8> = .init(OpaquePointer(bitmap.data))
        
        let ms: Int = min(ss, ts)
        for _ in 0..<size.height {
            memcpy(target, source, ms)
            
            source = source.advanced(by: ss)
            target = target.advanced(by: ts)
        }
    }
    
    func bitmap(for plane: Int32) -> Void {
//        let chroma =
        
    
    }
    
    func setProfile(_ profile: ColorProfile) throws {
        guard profile.data.count > 0 else { return }
        
        let string = String(cString: profile.pointer.assumingMemoryBound(to: UInt8.self))
        print("string: \(string)")
        print("prof: \(profile.length)")
        
        //        var x: UInt32 = heif_color_profile_type_rICC.rawValue
        //
        //        let p = UnsafeRawPointer(&x)
        //        let p2: UnsafePointer<UInt8>? = p.assumingMemoryBound(to: UInt8.self)
        
        ////        let type: [UInt8] = ["r", "i", "c", "c"]
        //        let x = UnsafePointer(&heif_color_profile_type_rICC)
        //        let p = UnsafeMutablePointer(mutating: heif_color_profile_type_rICC)
        //
        //        let type = OpaquePointer(&heif_color_profile_type_rICC)
        
        let error = heif_image_set_raw_color_profile(ptr,
                                                     "prof",
                                                     profile.pointer,
                                                     profile.length)
        if error.exists {
            throw error
        }
    }
    
    //    public typealias Plane = UnsafeMutablePointer<UInt8>
    //    public func write(block: (Plane, Plane, Plane, Int, Int, Int)->()) {
    //        var sY: Int32 = 0
    //        var sCb: Int32 = 0
    //        var sCr: Int32 = 0
    //        let Y = heif_image_get_plane(image, heif_channel_Y, &sY)
    //        let Cb = heif_image_get_plane(image, heif_channel_Cb, &sCb)
    //        let Cr = heif_image_get_plane(image, heif_channel_Cr, &sCr)
    //        print("sY \(sY)")
    //        print("sCb \(sCb)")
    //        print("sCr \(sCr)")
    //        block(Y!, Cb!, Cr!, Int(sY), Int(sCb), Int(sCr))
    //    }
    
    public var image: Image {
        let chroma = heif_image_get_chroma_format(ptr)
        print(chroma)

        fatalError()
    }
    
}


extension HEIFImage {
    
    public func encode(context: HEIFContext, encoder: HEIFEncoder) throws -> heif_image_handle_ptr {
        
        print("image: \(self)")
        print("   size: \(heif_image_get_width(ptr, heif_channel_Y))x\(heif_image_get_height(ptr, heif_channel_Y))")
        
        var result: OpaquePointer?
        let error = heif_context_encode_image(context.context,
                                              self.ptr,
                                              encoder.encoder,
                                              nil,
                                              &result)
        if error.exists { throw error }
        
        return result!
    }
    
}
