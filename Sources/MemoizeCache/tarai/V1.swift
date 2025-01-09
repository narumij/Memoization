import RedBlackTreeModule

enum Memoized_Ver1 {

  static func tarai(x: Int, y: Int, z: Int) -> Int {

    typealias Key = (x: Int, y: Int, z: Int)

    enum KeyCustom: _KeyCustomProtocol {
      @inlinable @inline(__always)
      static func value_comp(_ a: Key, _ b: Key) -> Bool { a < b }
    }

    var storage: _MemoizeCacheBase<KeyCustom, Int> = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = storage[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      storage[args] = r
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

enum Memoized_Ver1_Hashable {
  
  static func tarai(x: Int, y: Int, z: Int) -> Int {

    struct Params: Hashable {
      init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
      }
      let x: Int
      let y: Int
      let z: Int
    }

    let maxCount: Int? = nil
    var storage: [Params:Int] = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = Params(x: x, y: y, z: z)
      if let result = storage[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      if let maxCount, storage.count == maxCount {
        storage.remove(at: storage.indices.randomElement()!)
      }
      storage[args] = r
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
