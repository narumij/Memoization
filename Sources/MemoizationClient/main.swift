import Memoization

@Memoize
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}

@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  x <= y ? y : tarai(x: tarai(x: x - 1, y: y, z: z), y: tarai(x: y - 1, y: z, z: x), z: tarai(x: z - 1, y: x, z: y))
}

print(fib(90))
print(tarai(x: 24, y: 12, z: 0))

var cache = CountingCache(Memo<Int, Int>.Cache<Dictionary>())
print(fib(80, cache: &cache), cache.hits, cache.misses)
