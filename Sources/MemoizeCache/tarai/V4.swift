import RedBlackTreeModule

enum Memoized_Ver4 {

  static var tarai: Decorate { .init() }

  // こちらは将来的に欲しいが、未可決課題が多いことと仕様未考慮が多いこともあり、
  // swift-ac-memoizeとしては、一旦キャンセル
  @dynamicCallable
  class Decorate: _MemoizationProtocol {

    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
      tarai(x: args[0].value, y: args[1].value, z: args[2].value)
    }

    typealias Parameter = (x: Int, y: Int, z: Int)
    typealias Return = Int
    static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }

    var memo: Tree = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {

      func tarai(x: Int, y: Int, z: Int) -> Int {
        let args = (x, y, z)
        if let result = memo[args] {
          return result
        }
        let r = body(x: x, y: y, z: z)
        memo[args] = r
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

    func cachClear() {
      memo.clear()
    }

    func cacheInfo() -> [String:Any] {
      [:]
    }
  }
}

struct Memoized_Ver4_Hashable {
  
  func tarai(_ x: Int, y: Int, z: Int) -> Int
  {
    if x <= y {
      return y
    } else {
      return tarai(
        tarai(x - 1, y: y, z: z),
        y: tarai(y - 1, y: z, z: x),
        z: tarai(z - 1, y: x, z: y))
    }
  }
  
  var _memoize_decorated_tarai_x_Int_y_Int_z_Int_Int: Decorate = .init()
  
  mutating func tarai(x: Int, y: Int, z: Int) -> Int {
    _memoize_decorated_tarai_x_Int_y_Int_z_Int_Int.tarai(x: x, y: y, z: z)
  }
  
  struct Decorate {

    mutating func cachClear(keepingCapacity flag: Bool = false) {
      memo.removeAll(keepingCapacity: flag)
    }

    func cacheInfo() -> [Parameters:Int] {
      memo
    }

    struct Parameters: Hashable {
      init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
      }
      let x: Int
      let y: Int
      let z: Int
    }
    
    typealias Return = Int

    var memo: [Parameters:Int] = .init()
    let maxCount: Int? = nil

    mutating func tarai(x: Int, y: Int, z: Int) -> Int {
      
      func tarai(x: Int, y: Int, z: Int) -> Int {
        let args = Parameters(x: x, y: y, z: z)
        if let result = memo[args] {
          return result
        }
        let r = body(x: x, y: y, z: z)
        if let maxCount, memo.count == maxCount {
          memo.remove(at: memo.indices.randomElement()!)
        }
        memo[args] = r
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
}
