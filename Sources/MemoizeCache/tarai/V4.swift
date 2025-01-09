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
