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

