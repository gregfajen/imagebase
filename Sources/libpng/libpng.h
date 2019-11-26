//
//  libpng.h
//  
//  Created by Greg Fajen on 11/13/19.
//

#if __linux__

#import "sys/types.h"
#include <time.h>
#include "/usr/include/libpng/png.h"

#elif __APPLE__

#include "/usr/local/Cellar/libpng/1.6.37/include/png.h"

#endif

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

