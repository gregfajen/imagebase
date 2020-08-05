// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "ImageBase",
    
    products: [
        .library(name: "ImageBase", targets: ["ImageBase"]),
        .executable(name: "RunAndPlay", targets: ["RunAndPlay"])
    ],
    
    dependencies: [],
    
    targets: [
        // core
        .systemLibrary(name: "mem"),
        .target(name: "ImageBaseCore", dependencies:["mem"]),
        
        // libjpeg
        .systemLibrary(name: "libjpeg",
                       pkgConfig: "libjpeg",
                       providers: [.apt(["libjpeg-dev"]), .brew(["libjpeg"])]),
        .target(name: "libjpeg-swift",
                dependencies: ["libjpeg", "ImageBaseCore"]),

        // libpng
        .systemLibrary(name: "libpng",
                       pkgConfig: "libpng",
                       providers: [.apt(["libpng"]), .brew(["libpng"])]),
        .target(name: "libpng-swift",
                dependencies: ["libpng", "ImageBaseCore"]),
        
        // libheif
        .systemLibrary(name: "libheif",
                       pkgConfig: "libheif",
                       providers: [.apt(["libheif-dev"]), .brew(["libheif"])]),
        .target(name: "libheif-swift",
                dependencies: ["libheif", "ImageBaseCore"]),
        
        // libwebp
        .systemLibrary(name: "libwebp",
                       pkgConfig: "libwebp",
                       providers: [.apt(["libwebp-dev"]), .brew(["webp"])]),
        .target(name: "libwebp-swift",
                dependencies: ["libwebp", "ImageBaseCore"]),
        
        
        // giflib
        .systemLibrary(name: "giflib",
                       pkgConfig: "giflib",
                       providers: [.apt(["libgif-dev"]), .brew(["giflib"])]),
        .target(name: "giflib-swift",
                dependencies: ["giflib", "ImageBaseCore"]),

        // umbrella
        .target(name: "ImageBase",
                dependencies: ["libjpeg-swift", "libpng-swift", "libheif-swift", "libwebp-swift", "giflib-swift"]),
        .target(name: "RunAndPlay",
                dependencies: ["ImageBase"])
        
    ]
)

