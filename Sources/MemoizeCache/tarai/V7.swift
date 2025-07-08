import RedBlackTreeModule

#if true
enum Memoized_Ver7_Comparable {

  static func tarai(x: Int, y: Int, z: Int) -> Int {

    typealias Params = Pack<Int,Int,Int>
    typealias Memo = Params.Base<Int>
    
    var _memo: Memo = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = Params(x, y, z)
      if let result = _memo[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      _memo[args] = r
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


enum Memoized_Ver7_Hashable {
  
  static func tarai(x: Int, y: Int, z: Int) -> Int {

    let cache: Cache<Int,Int,Int,Int>.Standard = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      cache[.init(x,y,z), fallBacking: body]
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
#endif
