//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/17/19.
//

#include <stddef.h>
#include <stdio.h>

#if __linux__

#include "/usr/include/jpeglib.h"

#elif __APPLE__

#include "/usr/local/Cellar/jpeg/9c/include/jpeglib.h"

#endif
