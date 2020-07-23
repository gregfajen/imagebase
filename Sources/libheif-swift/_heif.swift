//
//  heif.swift
//  App
//
//  Created by Greg Fajen on 11/13/19.
//

import Foundation
import libheif

//extension HEIFImage {
//
//    func convert() {
//        heif_image_co
//    }
//
//}

class WriterHelper {
    
    var data: Data?
    
}

func heif_read(data: Data) throws -> HEIFImage {
    let context = HEIFContext()
    _ = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
        heif_context_read_from_memory_without_copy(context.context, pointer.baseAddress, data.count, nil)
    }
    
    var handle: OpaquePointer?
    heif_context_get_primary_image_handle(context.context, &handle);
    
    var image: OpaquePointer?
    
    if heif_image_handle_has_alpha_channel(handle) == 0 {
        heif_decode_image(handle, &image, heif_colorspace_RGB, heif_chroma_interleaved_RGB, nil)
    } else {
        heif_decode_image(handle, &image, heif_colorspace_RGB, heif_chroma_interleaved_RGBA, nil)
    }
    
    return HEIFImage(image!)
}

func heif_write(image: HEIFImage) throws -> Data {
    
    
    let context = HEIFContext()
    let encoder = try HEIFEncoder()
    encoder.lossyQuality = 30
    
    _ = try image.encode(context: context, encoder: encoder)
    
//    let fun: Int
    var writer: heif_writer = heif_writer(writer_api_version: 1) { (ctx, data, size, userdata) -> heif_error in
        print("WRITE! \(String(describing: ctx)) \(String(describing: data)) \(size) \(String(describing: userdata))")
        
        let x = Data(bytes: data!.assumingMemoryBound(to: UInt8.self), count: size)
        
        guard let helper = userdata?.assumingMemoryBound(to: WriterHelper.self) else { fatalError() }
        helper.pointee.data = x
        
        return heif_error()
    }
    
    var helper = WriterHelper()
    
//    context.
    
 
    let error = heif_context_write(context.context, &writer, &helper)
    if error.exists { throw error }
    
    return helper.data!
//    fatalError()
    
//heif_context* ctx = heif_context_alloc();
//
//// get the default encoder
//heif_encoder* encoder;
//heif_context_get_encoder_for_format(ctx, heif_compression_HEVC, &encoder);
//
//// set the encoder parameters
//heif_encoder_set_lossy_quality(encoder, 50);
//
//// encode the image
//heif_image* image; // code to fill in the image omitted in this example
//heif_context_encode_image(ctx, nullptr, image, encoder);
//
//heif_encoder_release(encoder);
//
//heif_context_write_to_file(context, "output.heic");
}






