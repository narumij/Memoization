import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MemoizeMacros)
  import MemoizeMacros

  fileprivate let testMacros: [String: Macro.Type] = [
    "InlineCache": InlineMemoizeMacro.self,
  ]
#endif

final class InlineMemoizeTests: XCTestCase {
  func testMacro() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @InlineCache(maxCount: 0)
        func test(_ a: Int) -> Int {
          if a == 10 {
            return 10
          }
          return a + test(a - 1)
        }
        """,
        expandedSource: """
          func test(_ a: Int) -> Int {
              typealias Params = Pack<Int>
              typealias Memo = Params.Cache.LRU<Int>
              var test_cache: Memo = .init()
              func test(_ a: Int) -> Int {
                let params = Params(a)
                if let result = test_cache[params] {
                  return result
                }
                let r = ___body(a)
                test_cache[params] = r
                return r
              }
              func ___body(_ a: Int) -> Int {
                if a == 10 {
                  return 10
                }
                return a + test(a - 1)
              }
              return test(a)
          }
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testMacro2() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @InlineCache(maxCount: Int.max)
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
          if x <= yy {
            return yy
          } else {
            return tarai(
              tarai(x - 1, y: yy, z: z),
              y: tarai(yy - 1, y: z, z: x),
              z: tarai(z - 1, y: x, z: yy))
          }
        }
        """,
        expandedSource: """
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
            typealias Params = Pack<Int, Int, Int>
            typealias Memo = Params.Cache.LRU<Int>
            var tarai_cache: Memo = .init()
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              let params = Params(x, yy, z)
              if let result = tarai_cache[params] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              tarai_cache[params] = r
              return r
            }
            func ___body(_ x: Int, y yy: Int, z: Int) -> Int {
              if x <= yy {
                return yy
              } else {
                return tarai(
                  tarai(x - 1, y: yy, z: z),
                  y: tarai(yy - 1, y: z, z: x),
                  z: tarai(z - 1, y: x, z: yy))
              }
            }
            return tarai(x, y: yy, z: z)
        }
        """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
  
  func testMacro3() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @InlineCache
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
          if x <= yy {
            return yy
          } else {
            return tarai(
              tarai(x - 1, y: yy, z: z),
              y: tarai(yy - 1, y: z, z: x),
              z: tarai(z - 1, y: x, z: yy))
          }
        }
        """,
        expandedSource: """
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
            typealias Params = Pack<Int, Int, Int>
            typealias Memo = Params.Cache.Standard<Int>
            var tarai_cache: Memo = .init()
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              let params = Params(x, yy, z)
              if let result = tarai_cache[params] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              tarai_cache[params] = r
              return r
            }
            func ___body(_ x: Int, y yy: Int, z: Int) -> Int {
              if x <= yy {
                return yy
              } else {
                return tarai(
                  tarai(x - 1, y: yy, z: z),
                  y: tarai(yy - 1, y: z, z: x),
                  z: tarai(z - 1, y: x, z: yy))
              }
            }
            return tarai(x, y: yy, z: z)
        }
        """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
