//
//  V6.swift
//  Memoization
//
//  Created by narumij on 2025/01/13.
//

//import Memoization

#if false
func AA() {
  
  func B(_ c: Int) -> Int {
    assert(false, "use _B instead")
    return 0
  }

  do {
    
    func _B(_ c: Int) -> Int {
      typealias ___C = ___MemoizationCache___B
      let params = ___C.params(c)
      if let result = B_cache[params] {
        return result
      }
      let r = ___body(c)
      B_cache[params] = r
      return r
    }
    
    func ___body(_ c: Int) -> Int {
      return 0
    }
    
    enum ___MemoizationCache___B: _HashableMemoizationCacheProtocol {
      @usableFromInline struct Parameters: Hashable {
        @usableFromInline let c: Int
        init(_ c: Int) {
          self.c = c
        }
      }
      @usableFromInline typealias Return = Int
      @usableFromInline typealias Instance = Standard
      @inlinable @inline(__always)
      static func params(_ c: Int) -> Parameters {
        Parameters(c)
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init()
      }
    }
    
    var B_cache = ___MemoizationCache___B.create()
  }
  
  return _B(0)
}
#endif

