/// 再帰関数をメモ化する。
///
/// 元の関数は関数内のローカル辞書でメモ化される。
/// あわせて`cache: inout some MemoCache<キー, 戻り値型>`を末尾に足した
/// 多重定義と、キャッシュの型の別名`関数名Cache<キャッシュの型>`が生成され、
/// キャッシュの置き場所は呼び出し側が決められる。
///
/// キーは引数が1つならその型、2〜4つなら`MemoizePack2`〜`MemoizePack4`、5つ以上なら`MemoizePack`。
@attached(body)
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoize() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")

/// `cache: inout some MemoCache<キー, 戻り値型>`を末尾に足した多重定義と、
/// キャッシュの型の別名`関数名Cache<キャッシュの型>`だけを生成する。
///
/// 元の関数には手を付けない。キャッシュは呼び出し側が渡す。
@attached(peer, names: overloaded, suffixed(Cache))
public macro Memoizable() = #externalMacro(module: "MemoizationMacros", type: "MemoizeMacro")
