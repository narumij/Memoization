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
              var test_cache: Pack<Int>.LRU<Int> = .init(maxCount: 0)
              func test(_ a: Int) -> Int {
                if let result = test_cache[.init(a)] {
                  return result
                }
                let r = ___body(a)
                test_cache[.init(a)] = r
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
            var tarai_cache: Pack<Int, Int, Int>.LRU<Int> = .init(maxCount: Int.max)
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              if let result = tarai_cache[.init(x, yy, z)] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              tarai_cache[.init(x, yy, z)] = r
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
            var tarai_cache: Pack<Int, Int, Int>.Standard<Int> = .init()
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              if let result = tarai_cache[.init(x, yy, z)] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              tarai_cache[.init(x, yy, z)] = r
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
