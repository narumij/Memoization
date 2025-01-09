import Foundation

// 楽に使えるのは、キャッシュがローカルスコープのもののみ。

// メモ化デコレータを出力するようにし、あとはユーザーに委ねるのが吉かも？

// @Memoize(maxCount: 15)
func fibonacci(_ n: Int) -> Int {
    if n <= 1 { return n }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

enum A<B: FixedWidthInteger> {
  
  // Error: Static stored properties not supported in generic types
  // nonisolated(unsafe) static var context: Int = 0
  
  static func fibonacci(_ n: B) -> B {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }

  func fibonacci(_ n: B) -> B {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }
}

enum B<C: FixedWidthInteger> {
}

extension B {
  
  static func fibonacci(_ n: C) -> C {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }

  func fibonacci(_ n: C) -> C {
      if n <= 1 { return n }
      return fibonacci(n - 1) + fibonacci(n - 2)
  }
}

