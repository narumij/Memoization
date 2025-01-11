import RedBlackTreeModule

// 参考: https://docs.python.org/ja/3/library/functools.html#functools.lru_cache

struct Memoized_Ver3 {
  // ヒューで欲しくなる可能性はある。

  // ユーザーコードと衝突しない名前を生成する工夫が必要そう
  private class LocalCache_Memoized_Ver3_tarai {
    enum Memoize: _MemoizationProtocol {
      typealias Parameter = (x: Int, y: Int, z: Int)
      typealias Return = Int
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }
    }
    var memo: Memoize.Base = .init()
  }

  // ユーザーコードと衝突しない名前を生成する工夫が必要そう
  private let _memoized_ver3_tarai_cache = LocalCache_Memoized_Ver3_tarai()

  func tarai(x: Int, y: Int, z: Int) -> Int {

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = _memoized_ver3_tarai_cache.memo[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      _memoized_ver3_tarai_cache.memo[args] = r
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

