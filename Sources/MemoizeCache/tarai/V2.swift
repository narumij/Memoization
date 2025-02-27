import RedBlackTreeModule

enum Memoized_Ver2 {

  static func tarai(x: Int, y: Int, z: Int) -> Int {

    // この方式はユーザーにとって非直感的となり、pythonと比べても不便さが残るので、
    // swift-ac-memoizeとしてはキャンセル
    // デコレータ版が優先するので、参考実装にとどまる
    class GlobalCache {
      enum Memoize: _ComparableMemoizationCacheProtocol {
        typealias Parameters = (x: Int, y: Int, z: Int)
        typealias Return = Int
        @inlinable @inline(__always)
        static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool { a < b }
      }
      nonisolated(unsafe) static var cache: Memoize.Base = .init()
      var memo: Memoize.Base {
        get { Self.cache }
        _modify { yield &Self.cache }
      }
    }

    class Cache {
      enum Memoize: _ComparableMemoizationCacheProtocol {
        typealias Parameters = (x: Int, y: Int, z: Int)
        typealias Return = Int
        @inlinable @inline(__always)
        static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool { a < b }
      }
      var memo: Memoize.Base = .init()
    }

    let cache = Cache()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = cache.memo[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      cache.memo[args] = r
      return r
    }

    func body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: z, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }

    return tarai(x: x, y: y, z: z)
  }
}
