import Memoize

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

@Memoize(maxCount: 15)
func fibonacci(_ n: Int) -> Int {
    if n <= 1 { return n }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

print(fibonacci(40)) // Output: 102_334_155

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

print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))")

#if true
@AddCache(maxCount:1000)
func tarai2(x: Int, y: Int, z: Int) -> Int {
  if x <= y {
    return y
  } else {
    return tarai2(
      x: tarai2(x: x - 1, y: y, z: z),
      y: tarai2(x: y - 1, y: z, z: x),
      z: tarai2(x: z - 1, y: x, z: y))
  }
}

print("Tak 20 10 0 is \(tarai2(x: 20, y: 10, z: 0))")

print(tarai2_cache.count)
#endif

class Fib {
  var one: Int { 1 }
  var two: Int { 2 }
  @AddCache(maxCount:150)
  func fibonacci(_ n: Int) -> Int {
      if n <= one { return n }
      return fibonacci(n - one) + fibonacci(n - two)
  }
}

let fib = Fib()

print(fib.fibonacci(40)) // Output: 102_334_155

print(fib.fibonacci_cache.count)


class Fib2 {
  static var one: Int { 1 }
  static var two: Int { 2 }
  @AddCache(maxCount:150)
  static func fibonacci(_ n: Int) -> Int {
      if n <= one { return n }
      return fibonacci(n - one) + fibonacci(n - two)
  }
}

print(Fib2.fibonacci(40)) // Output: 102_334_155

print(Fib2.fibonacci_cache.count)
