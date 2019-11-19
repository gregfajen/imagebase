//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/19/19.
//

#import "setjmp.h"


void wrap_jump( void (*fn)(void *), void (*err)(void *), void* data, jmp_buf *env) {
    if (setjmp(*env)) {
        err(data);
        return;
    }
    
    fn(data);
}

void wrap_long_jump(jmp_buf *env) {
    longjmp(env, 1);
}
