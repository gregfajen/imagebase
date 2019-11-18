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

var filename = "/Users/greg/Desktop/test.jpg"

let image = try! JPEG.decode(path: filename)

print("\(image)")
print("    size: \(image.size.width)x\(image.size.height)")
print(" ")

//let half = try image.halved()



let data = try! HEIF.encode(image: image)
filename = "/Users/greg/Desktop/test.heif"
//let data = try! PNG.encode(image: image)
//filename = "/Users/greg/Desktop/wrong.png"
try! data.write(to: URL(fileURLWithPath: filename))
print("\(data)")
print("    count: \(data.count)")
print(" ")

//yield 

/// TODO:
/// libjpeg
/// libheif
/// resizing
///
/// more png options
/// check for transparancy
/// check for black and white
///


