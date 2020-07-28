#if os(Linux)
import Glibc
#endif

import Foundation
import libpng
import ImageBaseCore
import mem



typealias PNGError = GenericError<PNG>

private func jmpFn(data: Optional<OpaquePointer>, char: Optional<UnsafePointer<Int8>>) {
    let png: png_structp = data!
    let wrapper = png_get_error_ptr(png).assumingMemoryBound(to: JumpWrapper.self).pointee
    
    let string = String(cString: char!)
    wrapper.error = PNGError(string)
    wrapper.longJump()
}



func hex(_ byte: UInt8) -> String {
    return String(format: "%02x", byte)
}

extension ColorProfile {
    
    init?(_ r: png_iCCP_result) {
        let data = Data(bytes:     r.profile,
                        count: Int(r.proflen))
        
        self.init(data)
    }
    
}

extension PixelType {
    
    var pngType: Int32 {
        switch self {
            case .y: return PNG_COLOR_TYPE_GRAY
            case .ya: return PNG_COLOR_TYPE_GA
            case .rgb: return PNG_COLOR_TYPE_RGB
            case .rgba: return PNG_COLOR_TYPE_RGBA
        }
    }
    
}

public struct PNG: FileBasedDecoder, ImageEncoder {
    
    private static func decode<P: Pixel>(_ p: P.Type,
                                         _ size: Size,
                                         _ png: png_structp,
                                         _ info: png_infop) -> Image {
        let bitmap = Bitmap<P>(size)
        png_read_image(png, bitmap.rows)
        
        let prof = png_get_iCCP2(png, info)
        
        let image = Image(bitmap.as8Bit())
        image.profile = ColorProfile(prof)
        
        return image
    }
    
    private static func decode(_ type: Int32,
                               _ size: Size,
                               _ bitDepth: UInt8,
                               _ png: png_structp,
                               _ info: png_infop) throws -> Image {
        
        let is16: Bool
        switch bitDepth {
            case 8:  is16 = false
            case 16: is16 = true
            default: throw MiscError()
        }
        
        
        switch type {
            case PNG_COLOR_TYPE_GRAY:
                if is16 {
                    return decode(Mono<UInt16>.self, size, png, info)
                } else {
                    return decode(Mono<UInt8>.self, size, png, info)
                }
            
            case PNG_COLOR_TYPE_GA:
                if is16 {
                    return decode(MonoAlpha<UInt16>.self, size, png, info)
                } else {
                    return decode(MonoAlpha<UInt8>.self, size, png, info)
                }
            
            case PNG_COLOR_TYPE_RGB:
                if is16 {
                    return decode(RGB<UInt16>.self, size, png, info)
                } else {
                    return decode(RGB<UInt8>.self, size, png, info)
                }
            
            case PNG_COLOR_TYPE_RGBA:
                if is16 {
                    return decode(RGBA<UInt16>.self, size, png, info)
                } else {
                    return decode(RGBA<UInt8>.self, size, png, info)
                }
            
            default: fatalError()
        }
    }
    
    
    
    public static func decode(fp: UnsafeMutablePointer<FILE>) throws -> Image {
        try autoreleasepool {
            var wrapper = JumpWrapper()
//            print("wrapper: \(wrapper) \(UnsafeMutablePointer(&wrapper))")
            
            wrapper.errorHandler = { () -> Error in
                return MiscError()
            }
            
            return try wrapper.wrap { _ -> Image in
                var byte: UInt8 = 0
                fread(&byte, 1, 1, fp)
                let isPNG = png_sig_cmp(&byte, 1, 1) != 0
                print("byte: \(hex(byte)) (isPNG: \(isPNG))")
                guard isPNG else { throw MiscError() }
                
                guard let read: png_structp = png_create_read_struct(PNG_LIBPNG_VER_STRING,
                                                                     &wrapper,
                                                                     jmpFn,
                                                                     nil) else {
                                                                        throw MiscError()
                }
                let r2 = UnsafeMutablePointer<Optional<OpaquePointer>>(read)
                
                guard let info = png_create_info_struct(read) else {
                    png_destroy_read_struct(r2, nil, nil)
                    throw MiscError()
                }
                let i2 = UnsafeMutablePointer<Optional<OpaquePointer>>(info)
                
                png_init_io(read, fp)
                png_set_sig_bytes(read, 1)
                
                png_read_info(read, info);
                
                let width = Int(png_get_image_width(read, info))
                let height = Int(png_get_image_height(read, info))
                let color_type = Int32(png_get_color_type(read, info))
                let bit_depth = png_get_bit_depth(read, info)
                
                _ = png_set_interlace_handling(read);
                png_read_update_info(read, info);
                
                let image = try decode(color_type, Size(width, height), bit_depth, read, info)
                
                png_destroy_read_struct(r2, i2, nil)
                
                return image
            }
        }
    }
    
    static func encode<P>(_ bitmap: Bitmap<P>) throws -> Data {
        guard let png: png_structp = png_create_write_struct(PNG_LIBPNG_VER_STRING,
                                                             nil, nil, nil) else { throw MiscError() }
        
        let p2 = UnsafeMutablePointer<Optional<OpaquePointer>>(png)
        
        guard let info = png_create_info_struct(png) else {
            png_destroy_read_struct(p2, nil, nil)
            throw MiscError()
        }
        
        let fp = tmpfile();
        png_init_io(png, fp);
        
        let size = bitmap.size
        png_set_IHDR(png, info,
                     png_uint_32(size.width),
                     png_uint_32(size.height),
                     8,
                     P.pixelType.pngType,
                     PNG_INTERLACE_NONE,
                     PNG_COMPRESSION_TYPE_BASE,
                     PNG_FILTER_TYPE_BASE);
        
        png_set_compression_level(png, 5)
        
        png_write_info(png, info);
        
        png_write_image(png, bitmap.rows);
        png_write_end(png, nil);
        
        fseek(fp, 0, SEEK_SET)
        let data = Data(fp: fp!)
        
        fclose(fp)
        return data
    }
    
    public static func encode(image: Image, quality: Int) throws -> Data {
        switch image.backing {
            case .G(let bitmap): return try encode(bitmap)
            case .GA(let bitmap): return try encode(bitmap)
            case .RGB(let bitmap): return try encode(bitmap)
            case .RGBA(let bitmap): return try encode(bitmap)
            case .YCbCr, .YCbCrA: throw MiscError()
        }
    }
    
}










func hi(filename: String) throws {
    let fp = fopen(filename, "rb")
    if fp == nil { throw MiscError() }
    
    var byte: UInt8 = 0
    
    fread(&byte, 1, 1, fp)
    
    let isPNG = png_sig_cmp(&byte, 1, 1) == 0
    guard isPNG else { throw MiscError() }
    
    
    //    png_create
}

