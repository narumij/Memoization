# Memoization

English | [日本語](README.ja.md)

A macro that memoizes recursive functions, and small building blocks for swapping the memoization cache.

The macro does not hide the cache. The cache lives either inside the function or wherever the caller puts it.
No global variables or locks are involved, so isolation is left to the Swift compiler.

## Installation

Add the following to your Package.swift:
```
dependencies: [
  .package(url: "https://github.com/narumij/Memoization", branch: "main"),
],
```

Add the following to your build target:

```
  dependencies: [
    .product(name: "Memoization", package: "Memoization")
  ]
```

Add the following to your source code:
```
import Memoization
```

## Usage

Just add @Memoize in front of a recursive function.

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
print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // Output: 20
```

The code above expands roughly as follows:
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

The original function memoizes with a fresh dictionary on each call.
An overload with a trailing `cache:` parameter is generated alongside it.

## Keeping the cache outside

Pass a cache to the `cache:` overload to reuse it across calls.

```swift
var cache = Memo<Int, Int, Int, Int>.Cache<Dictionary>()
tarai(x: 20, y: 10, z: 0, cache: &cache)
tarai(x: 24, y: 12, z: 0, cache: &cache)
```

`Memo<ArgumentTypes..., ResultType>.Cache<CacheType>` names the cache type.
Write the cache type without type arguments; the key and value types are inferred.
The cache in the example above is `[MemoizePack<Int, Int, Int>: Int]`.

The cache can be a local variable, or a property of a struct or an actor.

```swift
actor Holder {
  var cache = Memo<Int, Int, Int, Int>.Cache<Dictionary>()

  func value(x: Int, y: Int, z: Int) -> Int {
    tarai(x: x, y: y, z: z, cache: &cache)
  }
}
```

## Swapping the cache

Any type that conforms to `MemoCache` can be used instead of `Dictionary`.

```swift
public protocol MemoCache<Key, Value>: ~Copyable {
  associatedtype Key
  associatedtype Value
  subscript(key: Key) -> Value? { mutating get set }
}
```

A type that already has `subscript(key:) -> Value?` conforms with an empty `extension`.

```swift
extension RedBlackTreeDictionary: MemoCache {}

var cache = Memo<Int, Int, Int, Int>.Cache<RedBlackTreeDictionary>()
```

Noncopyable types work too.

The cache type decides what the arguments must conform to.
For `Dictionary`, every argument type must be `Hashable`.
A mismatch is a compile error.

## Generating only the cache-taking function

`@Memoizable` generates only the `cache:` overload and leaves the original function as is.

```swift
@Memoizable
func steps(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : steps(Point(x: p.x - 1, y: p.y)) + steps(Point(x: p.x, y: p.y - 1))
}

var cache = Memo<Point, Int>.Cache<RedBlackTreeDictionary>()
steps(Point(x: 8, y: 8), cache: &cache)
```

`@Memoize` builds a `Dictionary` inside the function, so its argument types must be `Hashable`.
`@Memoizable` has no such restriction; the argument types only need to suit the cache you pass.

## Caching non-recursive functions

Without a macro, use `value(for:orCompute:)`.

```swift
var cache: [String: Int] = [:]
let n = cache.value(for: "abc") { "abc".count }
```

## Counting hits and misses

Wrap a cache in `CountingCache` to count hits and misses.
For noncopyable caches, use `NoncopyableCountingCache`.

```swift
var cache = CountingCache(Memo<Int, Int, Int, Int>.Cache<Dictionary>())
tarai(x: 20, y: 10, z: 0, cache: &cache)
print(cache.hits, cache.misses)
```

## Notes

- Works on functions that take at least one argument and return a value.
- Not supported: async, throws, or generic functions.
- Not supported: inout, some/any, or variadic parameters.
- If a parameter's internal name is `cache`, it collides with the generated `cache:` parameter and fails to compile.

## License

This library is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
