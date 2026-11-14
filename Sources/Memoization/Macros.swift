/// Memoizes a recursive function.
///
/// The original function is memoized with a local dictionary inside its body.
/// The macro also generates an overload that takes an extra trailing
/// `cache: inout some MemoCache<Key, Result>` parameter, and a cache type alias
/// `<functionName>Cache<Storage>`, so callers can decide where the cache lives.
///
/// The key is the argument type for one argument, `MemoizePack2`–`MemoizePack4` for two to four arguments,
/// and `MemoizePack` for five or more.
@attached(body)
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoize() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")

/// Generates only an overload with an extra trailing `cache: inout some MemoCache<Key, Result>` parameter
/// and a cache type alias `<functionName>Cache<Storage>`.
///
/// The original function is left untouched. The caller passes the cache.
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoizable() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")
