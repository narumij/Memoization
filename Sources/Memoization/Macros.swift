/// 再帰関数をメモ化する。
///
/// 元の関数は関数内のローカル辞書でメモ化される。
/// あわせて`cache: inout some MemoCache<MemoizePack<引数型...>, 戻り値型>`を末尾に足した
/// 多重定義が生成され、キャッシュの置き場所は呼び出し側が決められる。
@attached(body)
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoize() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")

/// `cache: inout some MemoCache<MemoizePack<引数型...>, 戻り値型>`を末尾に足した多重定義だけを生成する。
///
/// 元の関数には手を付けない。キャッシュは呼び出し側が渡す。
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoizable() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")
