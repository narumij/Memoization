// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import RedBlackTreeModule
@_exported import Synchronization

@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro Cache(maxCount: Int? = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

/// 関数内展開のみをするもの
///
/// TODO: Implement this
@attached(body)
public macro InlineCache(maxCount: Int? = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

/// キャッシュ変数展開のみをするもの
///
/// TODO: Implement this
@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro StoredCache(maxCount: Int? = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

// MARK: -

@attached(body)
public macro _Cache(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro2")

@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro LRUCache(maxCount: Int? = nil) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

