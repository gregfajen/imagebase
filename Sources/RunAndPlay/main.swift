//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/15/19.
//


import Foundation
import libpng_swift
import libpng

import libheif_swift
import libjpeg_swift

print("HI!")

//for i in [6,7,8] {
for i in 1...8 {
    
    var filename = "/Users/greg/Desktop/or_\(i).JPG"
    let image = try! JPEG.decode(path: filename)
    
    filename = "/Users/greg/Desktop/or_\(i)_out.jpg"
    let data = try! JPEG.encode(image: image)
    try! data.write(to: URL(fileURLWithPath: filename))
    
}



