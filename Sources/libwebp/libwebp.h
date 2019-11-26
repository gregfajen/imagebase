//
//  libwebp.h
//
//  Created by Greg Fajen on 11/13/19.
//

#if __linux__

#include "/usr/include/webp/types.h"
#include "/usr/include/webp/mux_types.h"
#include "/usr/include/webp/encode.h"
#include "/usr/include/webp/decode.h"
#include "/usr/include/webp/mux.h"
#include "/usr/include/webp/demux.h"

#elif __APPLE__

#include "/usr/local/Cellar/webp/1.0.3/include/webp/types.h"
#include "/usr/local/Cellar/webp/1.0.3/include/webp/mux_types.h"
#include "/usr/local/Cellar/webp/1.0.3/include/webp/encode.h"
#include "/usr/local/Cellar/webp/1.0.3/include/webp/decode.h"
#include "/usr/local/Cellar/webp/1.0.3/include/webp/mux.h"
#include "/usr/local/Cellar/webp/1.0.3/include/webp/demux.h"

#endif
