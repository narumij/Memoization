import Memoization

#if false
print("Tak 20 10 0 is \(V5_S_3.tarai(x: 20, y: 10, z: 0))")
print(V5_S_3.tarai_cache.withLock(\.info))
#endif

#if true
func B() {
  
//  @InlineCache
  @StoredCache // 展開した内容にさっぱり触れないので、ストアマクロの関数内展開は不可能
  func C(_ c: Int) -> Int {
    return 0
  }
  
  _ = C(1)
}
#endif

#if false
//@Cache(maxCount:150)
@Cache
//@LRUCache(maxCount: 150)
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

//tarai_cache.removeAll()

print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))")

print(tarai_cache.withLock(\.info))

func A() {
  
  @Cache
  func fib(_ n: Int) -> Int {
    n<2 ? n : fib(n-1) + fib(n-2)
  }
}

@LRUCache
func fib(_ n: Int) -> Int {
  n<2 ? n : fib(n-1) + fib(n-2)
}

print((0..<16).map { fib($0) })
print(fib_cache.withLock(\.info))

#if true
struct Main2 {
  @LRUCache(maxCount: 150)
  static func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
}
#endif

#if true
struct Main3 {
  @LRUCache(maxCount: 150)
  mutating func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
}
#endif

#if false
class Fib {
  var one: Int { 1 }
  var two: Int { 2 }
  @Memoized(maxCount:150)
  func fibonacci(_ n: Int) -> Int {
      if n <= one { return n }
      return fibonacci(n - one) + fibonacci(n - two)
  }
}

let fib = Fib()

fib.fibonacci_cache.removeAll()

print(fib.fibonacci(40)) // Output: 102_334_155

print(fib.fibonacci_cache.count)

class Fib2 {
  static var one: Int { 1 }
  static var two: Int { 2 }
  @Memoized(maxCount:150)
  static func fibonacci(_ n: Int) -> Int {
      if n <= one { return n }
      return fibonacci(n - one) + fibonacci(n - two)
  }
}

Fib2.fibonacci_cache.removeAll()

print(Fib2.fibonacci(40)) // Output: 102_334_155

print(Fib2.fibonacci_cache.count)
#endif

#endif
