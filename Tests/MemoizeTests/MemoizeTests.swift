import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MemoizeMacros)
  import MemoizeMacros

  fileprivate let testMacros: [String: Macro.Type] = [
    "Memoized": MemoizeMacro.self,
  ]
#endif

final class MemoizeTests: XCTestCase {

  func testMacro() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @Memoized
        func a(_ b: Int, c: Int, d dd: Int) -> Int {
          return 0
        }
        """,
        expandedSource: """
          func a(_ b: Int, c: Int, d dd: Int) -> Int {
              a_cache.withLock { a_cache in
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                a_cache[.init(b, c, dd), fallBacking: ___body]
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
              }
          }
          
          let a_cache = Mutex(MemoizeCache<Int, Int, Int, Int>.Standard())
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
  
  func testMacroWithStaticModifier() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @Memoized
        static func a(_ b: Int, c: Int, d dd: Int) -> Int {
          return 0
        }
        """,
        expandedSource: """
          static func a(_ b: Int, c: Int, d dd: Int) -> Int {
              a_cache.withLock { a_cache in
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                a_cache[.init(b, c, dd), fallBacking: ___body]
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
              }
          }
          
          let a_cache = Mutex(MemoizeCache<Int, Int, Int, Int>.Standard())
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
  
  func testMacroWithMaxCount() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @Memoized(maxCount: 999)
        func a(_ b: Int, c: Int, d dd: Int) -> Int {
          return 0
        }
        """,
        expandedSource: """
          func a(_ b: Int, c: Int, d dd: Int) -> Int {
              a_cache.withLock { a_cache in
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                a_cache[.init(b, c, dd), fallBacking: ___body]
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
              }
          }
          
          let a_cache = Mutex(MemoizeCache<Int, Int, Int, Int>.LRU(maxCount: 999))
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
