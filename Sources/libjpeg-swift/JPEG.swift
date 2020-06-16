//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

import Foundation
import libjpeg
import ImageBaseCore

typealias JPEGError = GenericError<JPEG>

private func jmpFn(info: Optional<UnsafeMutablePointer<jpeg_common_struct>>) {
    var info = info!.pointee
    let err = info.err.pointee
    
    let error: UnsafeMutablePointer<Int8>? = UnsafeMutablePointer<Int8>.allocate(capacity: Int(JMSG_LENGTH_MAX))
    err.format_message(&info, error)
    
    let string = String(cString: error!)
    print("string: \(string)")
    
    let wrapper = info.client_data.assumingMemoryBound(to: JumpWrapper.self).pointee
    wrapper.error = JPEGError(string)
    wrapper.longJump()
}


extension PixelType {
    
    var channelCount: Int {
        switch self {
            case .y: return 1
            case .ya: return 2
            case .rgb: return 3
            case .rgba: return 4
        }
    }
    
    var jSpace: J_COLOR_SPACE {
        switch self {
            case .y: return JCS_GRAYSCALE
            case .rgb: return JCS_RGB
            default: fatalError()
        }
    }
    
}

public struct JPEG: DataBasedDecoder, ImageEncoder {
    
    static let TRUE: boolean = .init(1)
    static let FALSE: boolean = .init(0)
    
    static func encode<P>(_ bitmap: Bitmap<P>) throws -> Data {
        var info: jpeg_compress_struct = .init()
        var err: jpeg_error_mgr = .init()
        
        info.err = jpeg_std_error(&err)
        jpeg_CreateCompress(&info,
                            JPEG_LIB_VERSION,
                            MemoryLayout<jpeg_compress_struct>.size)
        
        let fp = tmpfile();
        jpeg_stdio_dest(&info, fp);
        
        info.image_width = JDIMENSION(bitmap.size.width)
        info.image_height = JDIMENSION(bitmap.size.height)
        info.input_components = Int32(P.pixelType.channelCount)
        info.in_color_space = P.pixelType.jSpace
            
        jpeg_set_defaults(&info)
        jpeg_set_quality(&info, 50, FALSE)
        
        jpeg_start_compress(&info, TRUE)
        
        for row in bitmap.rowsBuffer {
            var row: UnsafeMutablePointer<UInt8>? = row
            jpeg_write_scanlines(&info, &row, 1)
        }
        
        jpeg_finish_compress(&info)
        
        fseek(fp, 0, SEEK_SET)
        let data = Data(fp: fp!)
        
        jpeg_destroy_compress(&info)
        fclose(fp)
        return data
    }
    
    public static func encode(image: Image) throws -> Data {
        switch image.removingAlpha().backing {
            case .G(let bitmap): return try encode(bitmap)
            case .RGB(let bitmap): return try encode(bitmap)
            case .GA, .RGBA, .YCbCr, .YCbCrA: throw MiscError()
        }
    }
    
    public static func decode(data: Data) throws -> Image {
        let wrapper = JumpWrapper()
        
        wrapper.errorHandler = { () -> Error in
            return MiscError()
        }
        
        return try wrapper.wrap { pointer -> Image in
            var info: jpeg_decompress_struct = .init()
            var err: jpeg_error_mgr = .init()
            
            info.err = jpeg_std_error(&err)
            err.error_exit = jmpFn
            info.client_data = pointer.baseAddress!
            
            jpeg_CreateDecompress(&info,
                                  JPEG_LIB_VERSION,
                                  MemoryLayout<jpeg_decompress_struct>.size)
            
            jpeg_mem_src(&info, data.address.assumingMemoryBound(to: UInt8.self), Int(data.count))
            jpeg_read_header(&info, TRUE);   // read jpeg file header
            
            jpeg_start_decompress(&info);    // decompress the file
            
            //set width and height
            let width = info.output_width;
            let height = info.output_height;
            let channels = info.num_components;
            
            print("\(width)x\(height)")
            print("scanline: \(info.output_scanline)")
            
            
            let orientation = getOrientation(from: data) ?? .up
            print("orientation: \(orientation) \(orientation.rawValue)")
            
            let image: Image
            if channels == 3 {
                let bitmap = Bitmap<RGB<UInt8>>(.init(width, height))
                for row in bitmap.rowsBuffer {
                    var row: UnsafeMutablePointer<UInt8>? = row
                    jpeg_read_scanlines(&info, &row, 1)
                }
                
                let reoriented = Bitmap<RGB<UInt8>>.from(bitmap, orientation)
                
                image = Image(reoriented)
            } else if channels == 1 {
                let bitmap = Bitmap<Mono<UInt8>>(.init(width, height))
                for row in bitmap.rowsBuffer {
                    var row: UnsafeMutablePointer<UInt8>? = row
                    jpeg_read_scanlines(&info, &row, 1)
                }
                
                let reoriented = Bitmap<Mono<UInt8>>.from(bitmap, orientation)
                
                image = Image(reoriented)
            } else {
                throw MiscError()
            }
            
            jpeg_finish_decompress(&info)
            jpeg_destroy_decompress(&info)
            
            
            return image
        }
    }
    
}


/*
 
 GLuint LoadJPEG(char* FileName)
 //================================
 {
 unsigned long x, y;
 unsigned int texture_id;
 unsigned long data_size;     // length of the file
 int channels;               //  3 =>RGB   4 =>RGBA
 unsigned int type;
 unsigned char * rowptr[1];    // pointer to an array
 unsigned char * jdata;        // data for the image
 struct jpeg_decompress_struct info; //for our jpeg info
 struct jpeg_error_mgr err;          //the error handler
 
 FILE* file = fopen(FileName, "rb");  //open the file
 
 info.err = jpeg_std_error(& err);
 jpeg_create_decompress(& info);   //fills info structure
 
 //if the jpeg file doesn't load
 if(!file) {
 fprintf(stderr, "Error reading JPEG file %s!", FileName);
 return 0;
 }
 
 jpeg_stdio_src(&info, file);
 jpeg_read_header(&info, TRUE);   // read jpeg file header
 
 jpeg_start_decompress(&info);    // decompress the file
 
 //set width and height
 x = info.output_width;
 y = info.output_height;
 channels = info.num_components;
 type = GL_RGB;
 if(channels == 4) type = GL_RGBA;
 
 data_size = x * y * 3;
 
 //--------------------------------------------
 // read scanlines one at a time & put bytes
 //    in jdata[] array. Assumes an RGB image
 //--------------------------------------------
 jdata = (unsigned char *)malloc(data_size);
 while (info.output_scanline < info.output_height) // loop
 {
 // Enable jpeg_read_scanlines() to fill our jdata array
 rowptr[0] = (unsigned char *)jdata +  // secret to method
 3* info.output_width * info.output_scanline;
 
 jpeg_read_scanlines(&info, rowptr, 1);
 }
 //---------------------------------------------------
 
 jpeg_finish_decompress(&info);   //finish decompressing
 
 //----- create OpenGL tex map (omit if not needed) --------
 glGenTextures(1,&texture_id);
 glBindTexture(GL_TEXTURE_2D, texture_id);
 gluBuild2DMipmaps(GL_TEXTURE_2D,3,x,y,GL_RGB,GL_UNSIGNED_BYTE,jdata);
 
 jpeg_destroy_decompress(&info);
 fclose(file);                    //close the file
 free(jdata);
 
 return texture_id;    // for OpenGL tex maps
 }
 
 
 */
