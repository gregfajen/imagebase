//
//  libpng.h
//  
//  Created by Greg Fajen on 11/13/19.
//

#if __linux__

#include "time.h"
#include "/usr/include/libpng/png.h"

#elif __APPLE__

#include "/usr/local/Cellar/libpng/1.6.37/include/png.h"

#endif



//typedef struct heif_context *heif_context_ptr;
//typedef struct heif_encoder *heif_encoder_ptr;
//typedef struct heif_image *heif_image_ptr;
//typedef struct heif_image_handler *heif_image_handler_ptr;

typedef struct {
    png_charp name;
    int compression_type;
    png_bytep profile;
    png_uint_32 proflen;
} png_iCCP_result;


png_iCCP_result png_get_iCCP2(png_const_structrp png_ptr,
                    png_inforp info_ptr) {
    png_iCCP_result r;
    r.proflen = 0;
    png_get_iCCP(png_ptr, info_ptr, &r.name, &r.compression_type, &r.profile, &r.proflen);
    
    return r;
}


//
//heif_encoder_result heif_context_get_encoder2(struct heif_context* context,
//                                              const struct heif_encoder_descriptor* encoding) {
//    heif_encoder_ptr encoder;
//    
//    printf("")
//    
//    struct heif_error error = heif_context_get_encoder(context, encoding, &encoder);
//    
//    heif_encoder_result result;
//    result.encoder = encoder;
//    result.error = error;
//    
//    return result;
//}
