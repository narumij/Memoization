// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import RedBlackTreeModule
@_exported import Synchronization

@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro Cache(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

@attached(body)
public macro _Cache(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro2")
