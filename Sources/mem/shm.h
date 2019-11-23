//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

#if __linux__
#include <sys/mman.h>
#include <sys/stat.h>        /* For mode constants */
#include <fcntl.h>
#elif __APPLE__
#import <sys/mman.h>
#endif

#import "mem.h"

int shm_open2(const char* name, int mode, int perm) {
    return shm_open(name, mode, perm);
}

