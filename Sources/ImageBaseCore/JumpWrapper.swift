//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/19/19.
//

import Foundation
import mem

#if os(Linux)
public func autoreleasepool<T>(_ f: () throws -> T) throws -> T { return try f() }
#endif

private func runFn(data: UnsafeMutableRawPointer!) {
    let wrapper = data.assumingMemoryBound(to: JumpWrapper.self).pointee
    wrapper.run()
}

private func errFn(data: UnsafeMutableRawPointer!) {
    let wrapper = data.assumingMemoryBound(to: JumpWrapper.self).pointee
    wrapper.err()
}

private func jmpFn(_ env: UnsafeMutablePointer<jmp_buf>) {
    wrap_long_jump(env)
}

//private func jmpFn(data: Optional<OpaquePointer>, char: Optional<UnsafePointer<Int8>>) {
//    let umrp = UnsafeMutableRawPointer(data!).assumingMemoryBound(to: png_st)
//    let ump = umrp.assumingMemoryBound(to: jmp_buf.self)
//
////    let p = UnsafeMutablePointer<JumpWrapper>(data)!
////    let wrapper = p.pointee
//    wrap_long_jump(ump)
//}

public class JumpWrapper {
    
    public var _env: jmp_buf
    public var env: UnsafeMutablePointer<jmp_buf>
    
    public init() {
        _env = UnsafeMutablePointer<jmp_buf>.allocate(capacity: 1).pointee
        env = UnsafeMutablePointer<jmp_buf>(&_env)
        
    }
    
    private var result: Any?
    public var error: Error?
    private var action: (() throws -> Any)?
    
    public var errorHandler: (()->Error)?
    
    fileprivate func run() {
        do {
            result = try action!();
        } catch let e {
            error = e
        }
    }
    
    fileprivate func err() {
        error = error ?? errorHandler?() ?? MiscError()
    }
    
    public func wrap<T>(_ f: @escaping () throws -> (T)) throws -> T {
        action = f
        
        var me = self
        wrap_jump(runFn, errFn, &me, env)
        
        if let error = error {
            throw error
        }

        return result as! T
    }
    
//    public var longjumper: @convention(c) (Optional<OpaquePointer>, Optional<UnsafePointer<Int8>>) -> () {
//        return jmpFn
//    }
    
    public func longJump() {
        jmpFn(env)
    }
    
}
