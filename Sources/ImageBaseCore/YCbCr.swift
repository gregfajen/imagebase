//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation

func convertRGBtoYCbCr(R: UInt8, G: UInt8, B: UInt8) -> (UInt8,UInt8,UInt8) {
    // actually YUV
    
    let R = Int(R)
    let G = Int(G)
    let B = Int(B)
    
    let Y = (77 * R + 150 * G + 29 * B) >> 8
    let U = (144 * (B - Y)) >> 8 + 128
    let V = (183 * (R - Y)) >> 8 + 128
    
    return (UInt8(Y.clamp(min: 0, max: 255)), UInt8(U.clamp(min: 0, max: 255)), UInt8(V.clamp(min: 0, max: 255)))
}

func convertRGBtoYCbCrRed(R: UInt8, G: UInt8, B: UInt8) -> (UInt8,UInt8,UInt8) {
    // actually YUV
    
    let R = Int(R)
    let G = Int(G)
    let B = Int(B)
    
    let Y = (77 * R + 150 * G + 29 * B) >> 8
    let U = (126 * (B - Y)) >> 8 + 128
    let V = (225 * (R - Y)) >> 8 + 128
    
    return (UInt8(Y.clamp(min: 0, max: 255)), UInt8(U.clamp(min: 0, max: 255)), UInt8(V.clamp(min: 0, max: 255)))
}

func convertRGBtoYCbCrOld(R: UInt8, G: UInt8, B: UInt8) -> (UInt8,UInt8,UInt8) {
    let R = Int(R)
    let G = Int(G)
    let B = Int(B)
    
    let Y1: Int = (R<<6)+(R<<1)+(G<<7)
    let Y2: Int = (B<<4)+(B<<3)+B
    let Y: Int  = 16+((Y1+G+Y2)>>8);
    
    let Cb1: Int = (R<<5)+(R<<2)+(R<<1)
    let Cb2: Int = (G<<6)+(G<<3)+(G<<1)
    let Cb3: Int = -(Cb1)-(Cb2)+(B<<7)-(B<<4)
    let Cb: Int = 128 + ((Cb3)>>8);
    
    let Cr1: Int = (G<<6)+(G<<5)-(G<<1)
    let Cr2: Int = (R<<7)-(R<<4)-(Cr1)
    let Cr3: Int = (B<<4)+(B<<1)
    let Cr: Int = 128 + ((Cr2-(Cr3))>>8);
    
    return (UInt8(Y), UInt8(Cb), UInt8(Cr))
}
