import RedBlackTreeModule
import Synchronization

#if true
struct V5_S_1 {
  
  mutating func tarai(x: Int, y: Int, z: Int) -> Int {
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x: x, y: y, z: z)
      if let result = tarai_cache[args] {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      tarai_cache[args] = r
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
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

  enum ___MemoizationCache___tarai: _MemoizationProtocol {
    @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
    @usableFromInline typealias Return = Int
    @usableFromInline typealias Instance = LRU
    @inlinable @inline(__always)
    static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
      a < b
    }
    static func create() -> Instance {
      .init(maxCount: 150)
    }
  }

  var tarai_cache = ___MemoizationCache___tarai.create()
}

struct V5_S_2 {
  
  static func tarai(x: Int, y: Int, z: Int) -> Int {
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x: x, y: y, z: z)
      if let result = tarai_cache.withLock({
        $0[args]
      }) {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      tarai_cache.withLock {
        $0[args] = r
      }
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
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

  enum ___MemoizationCache___tarai: _MemoizationProtocol {
    @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
    @usableFromInline typealias Return = Int
    @usableFromInline typealias Instance = LRU
    @inlinable @inline(__always)
    static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
      a < b
    }
    static func create() -> Instance {
      .init(maxCount: 150)
    }
  }

  static let tarai_cache = Mutex(___MemoizationCache___tarai.create())
}


class V5_C {
  
  func tarai(x: Int, y: Int, z: Int) -> Int {
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x: x, y: y, z: z)
      if let result = tarai_cache[args] {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      tarai_cache[args] = r
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
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

  enum ___MemoizationCache___tarai: _MemoizationProtocol {
    @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
    @usableFromInline typealias Return = Int
    @usableFromInline typealias Instance = LRU
    @inlinable @inline(__always)
    static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
      a < b
    }
    static func create() -> Instance {
      .init(maxCount: 150)
    }
  }

  var tarai_cache = ___MemoizationCache___tarai.create()
}

actor V5_A {
  
  func tarai(x: Int, y: Int, z: Int) -> Int {
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x: x, y: y, z: z)
      if let result = tarai_cache[args] {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      tarai_cache[args] = r
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
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

  enum ___MemoizationCache___tarai: _MemoizationProtocol {
    @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
    @usableFromInline typealias Return = Int
    @usableFromInline typealias Instance = LRU
    @inlinable @inline(__always)
    static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
      a < b
    }
    static func create() -> Instance {
      .init(maxCount: 150)
    }
  }

  var tarai_cache = ___MemoizationCache___tarai.create()
}
#endif
