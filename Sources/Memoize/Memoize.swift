// The Swift Programming Language
// https://docs.swift.org/swift-book

//@attached(body)
//@attached(peer, names: suffixed(_cache), suffixed(_parameters))
//public macro Memoized(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

@attached(body)
public macro Memoized(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro2")
