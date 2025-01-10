// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MemoizeMacros", type: "StringifyMacro")

@attached(body)
public macro Memoize(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeBodyMacro")

@attached(body)
@attached(peer, names: suffixed(_cache), suffixed(_parameters))
public macro AddCache(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeBodyMacro2")

