//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//

import Foundation
import mem

public class PseudoFile {
    
    let name: String
    public let fd: Int32
    public let ptr: UnsafeMutableRawPointer
    public let size: Int
    
    public init(_ size: Int) {
        let name = String(format: "%08x", arc4random())
        
        let shm_fd = shm_open2(name, O_CREAT | O_RDWR, 0666);
        ftruncate(shm_fd, off_t(size));
        
        let ptr = mmap(nil, size, PROT_WRITE, MAP_SHARED, shm_fd, 0);

        self.fd = shm_fd
        self.ptr = ptr!
        self.name = name
        self.size = size
    }
    
    public convenience init(_ data: Data) {
        self.init(data.count)
        memcpy(ptr, data.address, data.count)
    }
    
    deinit {
      shm_unlink(name)
    }
    
}
