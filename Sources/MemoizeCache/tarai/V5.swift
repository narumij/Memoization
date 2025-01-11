import RedBlackTreeModule
import Synchronization

enum ___MemoizationCache___tarai: _MemoizationProtocol {
  @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
  @usableFromInline typealias Return = Int
  @usableFromInline typealias Instance = LRU
  @inlinable @inline(__always)
  static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
    a < b
  }
  static func create() -> Instance {
    .init(maximumCapacity: 150)
  }
}

@available(macOS 15, *)
func test() {
  let a = ___MemoizationCache___tarai.create()
  print(a.info)
}

