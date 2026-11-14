import Memoization
import Testing

@Memoize
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}

@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  x <= y ? y : tarai(x: tarai(x: x - 1, y: y, z: z), y: tarai(x: y - 1, y: z, z: x), z: tarai(x: z - 1, y: x, z: y))
}

@Memoize
func paths(from r: Int, _ c: Int) -> Int {
  r == 0 || c == 0 ? 1 : paths(from: r - 1, c) + paths(from: r, c - 1)
}

struct Grid {
  let walls: Set<[Int]>

  @Memoize
  func count(r: Int, c: Int) -> Int {
    if walls.contains([r, c]) { return 0 }
    if r == 0 && c == 0 { return 1 }
    return (r > 0 ? count(r: r - 1, c: c) : 0) + (c > 0 ? count(r: r, c: c - 1) : 0)
  }
}

actor Holder {
  var cache = fibCache<Dictionary>()

  func fibonacci(_ n: Int) -> Int {
    fib(n, cache: &cache)
  }
}

struct MemoizationTests {

  @Test func singleArgument() {
    #expect(fib(90) == 2_880_067_194_370_816_120)
  }

  @Test func multipleArguments() {
    #expect(tarai(x: 24, y: 12, z: 0) == 24)
  }

  @Test func labelsAndWildcards() {
    #expect(paths(from: 16, 16) == 601_080_390)
  }

  @Test func method() {
    #expect(Grid(walls: [[1, 1]]).count(r: 2, c: 2) == 2)
  }

  @Test func externalCacheIsReused() {
    var cache = fibCache<Dictionary>()
    #expect(fib(30, cache: &cache) == 832_040)
    #expect(cache.count == 31)
    #expect(fib(10, cache: &cache) == 55)
    #expect(cache.count == 31)
  }

  @Test func wrapperCountsHitsAndMisses() {
    var cache = CountingCache(fibCache<Dictionary>())
    #expect(fib(80, cache: &cache) == 23_416_728_348_467_685)
    #expect(cache.misses == 81)
    #expect(cache.hits == 78)
  }

  @Test func actorHeldCache() async {
    let holder = Holder()
    #expect(await holder.fibonacci(50) == 12_586_269_025)
    #expect(await holder.cache.count == 51)
  }

  @Test func nonRecursiveCaching() {
    var cache: [String: Int] = [:]
    var computed = 0
    for word in ["a", "bb", "a", "ccc", "bb"] {
      _ = cache.value(for: word) {
        computed += 1
        return word.count
      }
    }
    #expect(computed == 3)
    #expect(cache == ["a": 1, "bb": 2, "ccc": 3])
  }
}

/// コピーできないキャッシュ
struct NoncopyableCache: MemoCache, ~Copyable {
  var storage: [Int: Int] = [:]
  subscript(key: Int) -> Int? {
    get { storage[key] }
    set { storage[key] = newValue }
  }
}

struct NoncopyableCacheTests {

  @Test func noncopyable() {
    var cache = NoncopyableCache()
    #expect(fib(80, cache: &cache) == 23_416_728_348_467_685)
  }

  @Test func countingNoncopyable() {
    var cache = NoncopyableCountingCache(NoncopyableCache())
    #expect(fib(80, cache: &cache) == 23_416_728_348_467_685)
    #expect(cache.misses == 81)
    #expect(cache.hits == 78)
  }
}

struct CountingCacheCopyTests {

  @Test func copyable() {
    var cache = CountingCache(fibCache<Dictionary>())
    _ = fib(10, cache: &cache)
    let snapshot = cache
    _ = fib(20, cache: &cache)
    #expect(snapshot.misses == 11)
    #expect(cache.misses == 21)
  }
}

/// 比較はできるがハッシュはできない引数
struct Point: Comparable {
  var x: Int
  var y: Int
  static func < (a: Point, b: Point) -> Bool { (a.x, a.y) < (b.x, b.y) }
}

/// 比較だけでキーを探すキャッシュ
struct ComparableCache<Key: Comparable, Value>: MemoCache {
  var keys: [Key] = []
  var values: [Value] = []
  subscript(key: Key) -> Value? {
    get {
      guard let i = keys.firstIndex(where: { !($0 < key) && !(key < $0) }) else { return nil }
      return values[i]
    }
    set {
      guard let newValue else { return }
      keys.append(key)
      values.append(newValue)
    }
  }
}

@Memoizable
func steps(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : steps(Point(x: p.x - 1, y: p.y)) + steps(Point(x: p.x, y: p.y - 1))
}

nonisolated(unsafe) var squareCalls = 0

@Memoizable
func square(_ n: Int) -> Int {
  squareCalls += 1
  return n * n
}

struct MemoizableTests {

  @Test func originalIsUntouched() {
    // 元の関数はメモ化されない
    #expect(steps(Point(x: 4, y: 4)) == 70)
  }

  @Test func comparableOnlyArgument() {
    var cache = stepsCache<ComparableCache>()
    #expect(steps(Point(x: 8, y: 8), cache: &cache) == 12_870)
    #expect(cache.keys.count == 9 * 9 - 1)
  }

  @Test func nonRecursive() {
    squareCalls = 0
    var cache = squareCache<Dictionary>()
    #expect(square(3, cache: &cache) == 9)
    #expect(square(3, cache: &cache) == 9)
    #expect(squareCalls == 1)
  }
}

@Memoizable
func sum4(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Int { a + b + c + d }

@Memoizable
func sum5(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int) -> Int { a + b + c + d + e }

struct KeyByArityTests {

  @Test func keyTypes() {
    #expect(fibCache<Dictionary>.self == [Int: Int].self)
    #expect(pathsCache<Dictionary>.self == [MemoizePack2<Int, Int>: Int].self)
    #expect(taraiCache<Dictionary>.self == [MemoizePack3<Int, Int, Int>: Int].self)
    #expect(sum4Cache<Dictionary>.self == [MemoizePack4<Int, Int, Int, Int>: Int].self)
    #expect(sum5Cache<Dictionary>.self == [MemoizePack<Int, Int, Int, Int, Int>: Int].self)
  }

  @Test func fourAndFiveArguments() {
    var c4 = sum4Cache<Dictionary>()
    var c5 = sum5Cache<Dictionary>()
    #expect(sum4(1, 2, 3, 4, cache: &c4) == 10)
    #expect(sum5(1, 2, 3, 4, 5, cache: &c5) == 15)
  }
}
