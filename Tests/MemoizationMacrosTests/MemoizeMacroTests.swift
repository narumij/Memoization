import MemoizationMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class MemoizeMacroTests: XCTestCase {

  let macros: [String: Macro.Type] = ["Memoize": MemoizeMacro.self]

  func testExpansion() {
    assertMacroExpansion(
      """
      @Memoize
      public func tarai(x: Int, _ y: Int, z zz: Int) -> Int {
        x <= y ? y : tarai(x: tarai(x: x - 1, y, z: zz), tarai(x: y - 1, zz, z: x), z: tarai(x: zz - 1, x, z: y))
      }
      """,
      expandedSource: """
        public func tarai(x: Int, _ y: Int, z zz: Int) -> Int {
            var cache = taraiCache<Dictionary>()
            return tarai(x: x, y, z: zz, cache: &cache)
        }

        public typealias taraiCache<Storage: MemoCache & ~Copyable> = Storage where Storage.Key == MemoizePack3<Int, Int, Int>, Storage.Value == Int

        public func tarai(x: Int, _ y: Int, z zz: Int, cache: inout some MemoCache<MemoizePack3<Int, Int, Int>, Int> & ~Copyable) -> Int {
          func tarai(x: Int, _ y: Int, z zz: Int) -> Int {
            let key = MemoizePack3(x, y, zz)
            if let r = cache[key] {
              return r
            }
            let r = body(x: x, y, z: zz)
            cache[key] = r
            return r
          }
          func body(x: Int, _ y: Int, z zz: Int) -> Int {
           x <= y ? y : tarai(x: tarai(x: x - 1, y, z: zz), tarai(x: y - 1, zz, z: x), z: tarai(x: zz - 1, x, z: y))
         }
          return tarai(x: x, y, z: zz)
        }
        """,
      macros: macros
    )
  }

  func testRejectsAsync() {
    assertMacroExpansion(
      """
      @Memoize
      func f(_ n: Int) async -> Int { n }
      """,
      expandedSource: """
        func f(_ n: Int) async -> Int { n }
        """,
      diagnostics: [
        DiagnosticSpec(message: "@Memoize does not support async or throws", line: 1, column: 1),
        DiagnosticSpec(message: "@Memoize does not support async or throws", line: 1, column: 1),
      ],
      macros: macros
    )
  }
}
