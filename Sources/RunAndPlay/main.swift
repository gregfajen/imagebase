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
import libwebp_swift

import ImageBaseCore
import ImageBase

print("HI!")

var filename = "/Users/greg/Desktop/ness.png"
let image = try! PNG.decode(path: filename)

let data = try! WEBP.encode(image: image)
filename = "/Users/greg/Desktop/ness.webp"
try! data.write(to: URL(fileURLWithPath: filename))


//do {
//    print("TRYING PNG")
//    var filename = "/Users/greg/Desktop/original.png"
//    let image = try! PNG.decode(path: filename)
//
//
//let heif = try! HEIF.encode(image: image)
//filename = "/Users/greg/Desktop/orange.heic"
//    try! heif.write(to: URL(fileURLWithPath: filename))
    

//} catch let e {
//    print("PNG ERROR: \(e)")j
//}
 

//do {
//    print("TRYING JPEG")
//    let filename = "/Users/greg/Desktop/truncated.jpg"
//    let _ = try JPEG.decode(path: filename)
//} catch let e {
//    print("JPEG ERROR: \(e)")
//}
//
//print("SUCCESS!!! :)")


//let names = ["g", "ga", "rgb", "rgba"]
//let pixelTypes: [PixelType] = [.y, .ya, .rgb, .rgba]
//
//for (name, pixelType) in zip(names, pixelTypes) {
//    var filename = "/Users/greg/Desktop/\(name).png"
//    var image = try! PNG.decode(path: filename)
//    if !image.checkNeedsColor() { image = image.removingColor() }
//    if !image.checkNeedsAlpha() { image = image.removingAlpha() }
//
//    assert(image.backing.pixelType! == pixelType)
//
//    let targets: [MimeType] = [.heif]
//    for target in targets {
//        let data = try! target.encode(image: image)
//
//        filename = "/Users/greg/Desktop/\(name)_out.\(target.ext)"
//        try! data.write(to: URL(fileURLWithPath: filename))
//    }
//}


//for i in [6,7,8] {
//for i in 1...8 {
//
//    var filename = "/Users/greg/Desktop/or_\(i).JPG"
//    let image = try! JPEG.decode(path: filename)
//
//    filename = "/Users/greg/Desktop/or_\(i)_out.jpg"
//    let data = try! JPEG.encode(image: image)
//    try! data.write(to: URL(fileURLWithPath: filename))
//
//}



