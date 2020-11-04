//
//  libpng.h
//  
//  Created by Greg Fajen on 11/13/19.
//

#if __linux__

#import "sys/types.h"
#include <time.h>

#endif


#include <png.h>

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

png_color * png_get_palette(png_const_structrp png_ptr,
                            png_inforp info_ptr,
                            int32_t *count) {
    png_colorp palette = 0;
    png_get_PLTE(png_ptr, info_ptr, &palette, count);
    return palette;
}

png_byte * png_get_trans(png_const_structrp png_ptr,
                         png_inforp info_ptr,
                         int32_t *count) {
    png_bytep trans = 0;
    png_get_tRNS(png_ptr, info_ptr, &trans, count, 0);
    return trans;
}

