//
//  File.swift
//  
//
//  Created by Greg Fajen on 11/16/19.
//

import Foundation

public protocol Ub: UnsignedInteger, FixedWidthInteger {
    
//    associatedtype Next: Ub
    
    init(_ word: UInt64)
    init(normalizing: Double)
    
    func mix(_ other: Self, _ t: Float) -> Self
    
}

extension Ub {
    
    public func mix(_ other: Self, _ t: Float) -> Self {
        let f0 = Float(self)
        let f1 = Float(other)
        let r = f0 + (f1-f0)*t
        return Self(r)
    }
    
    public init<F: BinaryFloatingPoint>(normalizing f: F) {
        let m = Self.max
        self.init(truncatingIfNeeded: Int(round(F(m) * f)))
    }
    
}

extension UInt8: Ub { }
extension UInt16: Ub { }
extension UInt64: Ub { }

public enum PixelType {
    case y, ya, rgb, rgba
}

public protocol Pixel {
    
    associatedtype U: Ub
    associatedtype W: Pixel
    associatedtype Eight: Pixel
    associatedtype Sixteen: Pixel
    
    static var pixelType: PixelType { get }
    
    var eight: Eight { get }
    var w: W { get }
    init(_ w: W)
    
    static func + (l: Self, r: Self) -> Self // watch out for integer overflow!
    static func << (l: Self, r: Int) -> Self
    static func >> (l: Self, r: Int) -> Self
    
    func mix(_ other: Self, _ t: Float) -> Self
    
}

public struct Mono<U: Ub>: Pixel {
    
    public let v: U
    
    public static var pixelType: PixelType { return .y }
    
    public init(_ v: U) { self.v = v }
    
    public typealias Eight = Mono<UInt8>
    public typealias Sixteen = Mono<UInt16>
    public typealias W = Mono<UInt64>
    
    public init(_ w: W) {
        v = U(w.v)
    }
    
    public var eight: Mono<UInt8> {
        if let self = self as? Mono<UInt8> { return self }
        guard self is Mono<UInt16> else { fatalError() }
        
        return .init(UInt8(v>>8))
    }
    
    public var w: W {
        return .init(UInt64(v))
    }
    
    public static func + (l: Mono<U>, r: Mono<U>) -> Mono<U> {
        return .init(l.v + r.v)
    }
    
    public static func << (l: Mono<U>, r: Int) -> Mono<U> {
        return .init(l.v << r)
    }
    
    public static func >> (l: Mono<U>, r: Int) -> Mono<U> {
        return .init(l.v >> r)
    }
    
    public func mix(_ other: Self, _ t: Float) -> Self {
        return .init(v.mix(other.v, t))
    }
    
}

public struct MonoAlpha<U: Ub>: Pixel {
    
    public let v: U
    public let a: U
    
    public static var pixelType: PixelType { return .ya }
    
    public init(_ v: U, _ a: U) {
        self.v = v
        self.a = a
    }
    
    public typealias Eight = MonoAlpha<UInt8>
    public typealias Sixteen = MonoAlpha<UInt16>
    public typealias W = MonoAlpha<UInt64>
    
    public var eight: MonoAlpha<UInt8> {
        if let self = self as? MonoAlpha<UInt8> { return self }
        guard self is MonoAlpha<UInt16> else { fatalError() }
        
        return .init(UInt8(v>>8), UInt8(a>>8))
    }
    
    public init(_ w: W) {
        v = U(w.v)
        a = U(w.a)
    }
    public var w: W {
        return .init(UInt64(v), UInt64(a))
    }
    
    public static func + (l: MonoAlpha<U>, r: MonoAlpha<U>) -> MonoAlpha<U> {
        return .init(l.v + r.v,
                     l.a + r.a)
    }
    
    public static func << (l: MonoAlpha<U>, r: Int) -> MonoAlpha<U> {
        return .init(l.v << r,
                     l.a << r)
    }
    
    public static func >> (l: MonoAlpha<U>, r: Int) -> MonoAlpha<U> {
        return .init(l.v >> r,
                     l.a >> r)
    }
    
    public func mix(_ other: Self, _ t: Float) -> Self {
        return .init(v.mix(other.v, t),
                     a.mix(other.a, t))
    }
    
}

public struct RGB<U: Ub>: Pixel {
    
    public let r: U
    public let g: U
    public let b: U
    
    public static var pixelType: PixelType { return .rgb }
    
    public init(_ r: U, _ g: U, _ b: U) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    public init<F: BinaryFloatingPoint>(_ r: F, _ g: F, _ b: F) {
        self.r = U(normalizing: r)
        self.g = U(normalizing: g)
        self.b = U(normalizing: b)
    }
    
    public typealias Eight = RGB<UInt8>
    public typealias Sixteen = RGB<UInt16>
    public typealias W = RGB<UInt64>
    
    public init(_ w: RGB<UInt64>) {
        r = U(w.r)
        g = U(w.g)
        b = U(w.b)
    }
    
    public var eight: Eight {
        if let self = self as? Eight { return self }
        guard self is Sixteen else { fatalError() }
        
        return .init(UInt8(r>>8), UInt8(g>>8), UInt8(b>>8))
    }
    
    public var w: W {
        return .init(UInt64(r), UInt64(g), UInt64(b))
    }
    
    public static func + (l: RGB<U>, r: RGB<U>) -> RGB<U> {
        return .init(l.r+r.r, l.g+r.g, l.b+r.b)
    }
    
    public static func << (l: RGB<U>, r: Int) -> RGB<U> {
        return .init(l.r<<r,
                     l.g<<r,
                     l.b<<r)
    }
    
    public static func >> (l: RGB<U>, r: Int) -> RGB<U> {
        return .init(l.r>>r,
                     l.g>>r,
                     l.b>>r)
    }
    
    public func mix(_ other: Self, _ t: Float) -> Self {
        return .init(r.mix(other.r, t),
                     g.mix(other.g, t),
                     b.mix(other.b, t))
    }
    
}

public struct RGBA<U: Ub>: Pixel {
    
    public let r: U
    public let g: U
    public let b: U
    public let a: U
    
    public static var pixelType: PixelType { return .rgba }
    
    public init(_ r: U, _ g: U, _ b: U, _ a: U) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init<F: BinaryFloatingPoint>(_ r: F, _ g: F, _ b: F, _ a: U) {
        self.r = U(normalizing: r)
        self.g = U(normalizing: g)
        self.b = U(normalizing: b)
        self.a = a
    }
    
    public typealias Eight = RGBA<UInt8>
    public typealias Sixteen = RGBA<UInt16>
    public typealias W = RGBA<UInt64>
    
    public var eight: Eight {
        if let self = self as? Eight { return self }
        guard self is Sixteen else { fatalError() }
        
        return .init(UInt8(r>>8), UInt8(g>>8), UInt8(b>>8), UInt8(a>>8))
    }
    
    public init(_ w: RGBA<UInt64>) {
        r = U(w.r)
        g = U(w.g)
        b = U(w.b)
        a = U(w.a)
    }
    
    public var w: W {
        return .init(UInt64(r), UInt64(g), UInt64(b), UInt64(a))
    }
    
    public static func + (l: RGBA<U>, r: RGBA<U>) -> RGBA<U> {
        return .init(l.r+r.r, l.g+r.g, l.b+r.b, l.a+r.a)
    }
    
    public static func << (l: RGBA<U>, r: Int) -> RGBA<U> {
        return .init(l.r<<r,
                     l.g<<r,
                     l.b<<r,
                     l.a<<r)
    }
    
    public static func >> (l: RGBA<U>, r: Int) -> RGBA<U> {
        return .init(l.r>>r,
                     l.g>>r,
                     l.b>>r,
                     l.a>>r)
    }
    
    public func mix(_ other: Self, _ t: Float) -> Self {
        return .init(r.mix(other.r, t),
                     g.mix(other.g, t),
                     b.mix(other.b, t),
                     a.mix(other.a, t))
    }
    
}
