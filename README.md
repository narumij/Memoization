# Memoization

[swift-ac-memoize](https://github.com/narumij/swift-ac-memoize)で、DP問題のうちメモ化再帰問題用のマクロを作成しました。

## 利用の仕方

SwiftPMで swift-ac-libraryを利用する場合は、

以下をPackage.swift に追加してください。
```
dependencies: [
  .package(url: "https://github.com/narumij/Memoization", branch: "main"),
],
```

ビルドターゲットに以下を追加します。

```
  dependencies: [
    .product(name: "Memoize", package: "Memoization")
  ]
```

ソースコードに以下を追加します。
```
import Memoize
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
  
    let maxCount: Int? = nil
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = tarai_parameters(x: x, y: y, z: z)
      if let result = tarai_cache[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      if let maxCount, tarai_cache.count == maxCount {
        tarai_cache.remove(at: tarai_cache.indices.randomElement()!)
      }
      tarai_cache[args] = r
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

nonisolated(unsafe) var tarai_cache: [tarai_parameters: Int] = [:]

struct tarai_parameters: Hashable {
  init(x: Int, y: Int, z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }
  let x: Int
  let y: Int
  let z: Int
}

print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // 出力: 20
```

この場合、tarai_cacheとtarai_parametersが追加で生成されます。

キャッシュの生存期間はマクロ対象の関数のスコープによります。

キャッシュをクリアしたい場合は、

```
tarai_cache.removeAll()
```
としてください。

キャッシュサイズを制限したい場合は、パラメータを追加してマクロを利用してください。

```
@Memoize(maxCount: 100)
```

## 注意事項

- キャッシュサイズの上限の有無で、関数パラメータの各型が必要とする適合先が変わります。ナシの場合はHashable、アリの場合はComparableとなります。

- Comparableタイプのメモ化キャッシュは、CoWチェックすら省いて性能を絞り出しているため、コピーして利用した場合は未定義となります。

- 対象の関数を@inlinableにはできません。必要な場合、@usableFromInlineにしてください。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

