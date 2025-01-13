// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import RedBlackTreeModule
@_exported import Synchronization

/// 標準辞書を使用するもの
@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro Cache() = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

/// LRUを使用するもの
@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro LRUCache(maxCount: Int) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

/// 関数内展開のみをするもの
///
/// TODO: Implement this
///
/// 関数内関数での利用が可能
@attached(body)
public macro InlineCache() = #externalMacro(module: "MemoizeMacros", type: "InlineMemoizeMacro")

@attached(body)
public macro InlineLRUCache(maxCount: Int) = #externalMacro(module: "MemoizeMacros", type: "InlineMemoizeMacro")

/// キャッシュ変数展開のみをするもの
///
/// TODO: Implement this
///
/// 関数内関数での利用は不可
@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro StoredCache() = #externalMacro(module: "MemoizeMacros", type: "StoredMemoizeMacro")

@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro StoredLRUCache(maxCount: Int) = #externalMacro(module: "MemoizeMacros", type: "StoredMemoizeMacro")

// MARK: -

@attached(body)
public macro _Cache(maxCount: Int = Int.max) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro2")

@attached(body)
@attached(peer, names: suffixed(_cache), prefixed(___MemoizationCache___))
public macro LRUCache(maxCount: Int? = nil) = #externalMacro(module: "MemoizeMacros", type: "MemoizeMacro")

