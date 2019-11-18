//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

#if __linux__

#elif __APPLE__
#import <sys/mman.h>
#endif


int shm_open2(const char* name, int mode, int perm) {
    return shm_open(name, mode, perm);
}

//
//shm_open
//lj


