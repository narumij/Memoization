# Memoization

再帰関数をメモ化するマクロと、メモ化用のキャッシュを差し替えるための小さな部品です。

キャッシュはマクロが隠し持たず、関数の中か、呼び出し側が置いた場所にあります。
グローバル変数やロックを使わないので、isolationの扱いはSwiftのコンパイラに任せられます。

## 利用の仕方

以下をPackage.swift に追加してください。
```
dependencies: [
  .package(url: "https://github.com/narumij/Memoization", branch: "main"),
],
```

ビルドターゲットに以下を追加します。

```
  dependencies: [
    .product(name: "Memoization", package: "Memoization")
  ]
```

ソースコードに以下を追加します。
```
import Memoization
```

## 使い方

再帰関数の先頭に@Memoizeを付け足すだけです。

```swift
@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  if x <= y {
    return y
  } else {
    return tarai(
      x: tarai(x: x - 1, y: y, z: z),
      y: tarai(x: y - 1, y: z, z: x),
      z: tarai(x: z - 1, y: x, z: y))
  }
}
print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // 出力: 20
```

上のソースコードは、おおよそ以下のように展開されます。
```swift
func tarai(x: Int, y: Int, z: Int) -> Int {
  var cache = Memo<Int, Int, Int, Int>.Cache<Dictionary>()
  return tarai(x: x, y: y, z: z, cache: &cache)
}

func tarai(x: Int, y: Int, z: Int, cache: inout some MemoCache<MemoizePack<Int, Int, Int>, Int> & ~Copyable) -> Int {
  func tarai(x: Int, y: Int, z: Int) -> Int {
    let key = MemoizePack(x, y, z)
    if let r = cache[key] {
      return r
    }
    let r = body(x: x, y: y, z: z)
    cache[key] = r
    return r
  }
  func body(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
  return tarai(x: x, y: y, z: z)
}
```

元の関数は、呼ぶたびに新しい辞書でメモ化します。
あわせて、末尾に`cache:`を足した関数が生成されます。

## キャッシュを外に置く

`cache:`付きの関数にキャッシュを渡すと、呼び出しをまたいでキャッシュを使い回せます。

```swift
var cache = Memo<Int, Int, Int, Int>.Cache<Dictionary>()
tarai(x: 20, y: 10, z: 0, cache: &cache)
tarai(x: 24, y: 12, z: 0, cache: &cache)
```

`Memo<引数の型..., 戻り値の型>.Cache<キャッシュの型>`で、キャッシュの型が決まります。
キャッシュの型は型引数なしで書きます。キーと値の型は推論されます。
上の例のキャッシュは`[MemoizePack<Int, Int, Int>: Int]`です。

キャッシュの置き場所は、ローカル変数でも、構造体やアクターのプロパティでもかまいません。

```swift
actor Holder {
  var cache = Memo<Int, Int, Int, Int>.Cache<Dictionary>()

  func value(x: Int, y: Int, z: Int) -> Int {
    tarai(x: x, y: y, z: z, cache: &cache)
  }
}
```

## キャッシュを差し替える

`MemoCache`に適合した型なら、`Dictionary`の代わりに使えます。

```swift
public protocol MemoCache<Key, Value>: ~Copyable {
  associatedtype Key
  associatedtype Value
  subscript(key: Key) -> Value? { mutating get set }
}
```

`subscript(key:) -> Value?`を持つ型なら、空の`extension`で適合できます。

```swift
extension RedBlackTreeDictionary: MemoCache {}

var cache = Memo<Int, Int, Int, Int>.Cache<RedBlackTreeDictionary>()
```

コピーできない型も使えます。

キャッシュに必要な適合は、キャッシュの型が決めます。
例えば`Dictionary`なら、引数の型はすべて`Hashable`である必要があります。
合わない場合はコンパイルエラーになります。

## キャッシュを渡す関数だけを作る

`@Memoizable`は、`cache:`付きの関数だけを生成します。元の関数には手を付けません。

```swift
@Memoizable
func steps(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : steps(Point(x: p.x - 1, y: p.y)) + steps(Point(x: p.x, y: p.y - 1))
}

var cache = Memo<Point, Int>.Cache<RedBlackTreeDictionary>()
steps(Point(x: 8, y: 8), cache: &cache)
```

`@Memoize`は関数の中に`Dictionary`を作るため、引数の型が`Hashable`でないと使えません。
`@Memoizable`ならその制約がなく、キャッシュに合った引数の型であれば使えます。

## 再帰しない関数のキャッシュ

マクロを使わずに、`value(for:orCompute:)`でキャッシュできます。

```swift
var cache: [String: Int] = [:]
let n = cache.value(for: "abc") { "abc".count }
```

## ヒット数とミス数を数える

`CountingCache`で包むと、ヒット数とミス数を数えます。
コピーできないキャッシュには`NoncopyableCountingCache`を使います。

```swift
var cache = CountingCache(Memo<Int, Int, Int, Int>.Cache<Dictionary>())
tarai(x: 20, y: 10, z: 0, cache: &cache)
print(cache.hits, cache.misses)
```

## 注意事項

- 引数が1つ以上あり、戻り値がある関数に使えます。
- async、throws、ジェネリックな関数には使えません。
- inout、some/any、可変長の引数には使えません。
- 関数の中での引数名が`cache`の場合は、生成される関数の`cache:`と衝突してコンパイルエラーになります。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  
