import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MemoizeMacros)
  import MemoizeMacros

  let testMacros: [String: Macro.Type] = [
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
              let maxCount: Int? = nil
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                let args = a_parameters(b, c: c, d: dd)
                if let result = a_cache[args] {
                  return result
                }
                let r = body(b, c: c, d: dd)
                if let maxCount, a_cache.count == maxCount {
                  a_cache.remove(at: a_cache.indices.randomElement()!)
                }
                a_cache[args] = r
                return r
              }
              func body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
          }

          nonisolated(unsafe) var a_cache: [a_parameters: Int] = [:]

          struct a_parameters: Hashable {
            init(_ b: Int, c: Int, d dd: Int) {
              self.b = b
              self.c = c
              self.d = dd
            }
            let b: Int
            let c: Int
            let d: Int
          }
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
              let maxCount: Int? = nil
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                let args = a_parameters(b, c: c, d: dd)
                if let result = a_cache[args] {
                  return result
                }
                let r = body(b, c: c, d: dd)
                if let maxCount, a_cache.count == maxCount {
                  a_cache.remove(at: a_cache.indices.randomElement()!)
                }
                a_cache[args] = r
                return r
              }
              func body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
          }

          nonisolated(unsafe) static var a_cache: [a_parameters: Int] = [:]

          struct a_parameters: Hashable {
            init(_ b: Int, c: Int, d dd: Int) {
              self.b = b
              self.c = c
              self.d = dd
            }
            let b: Int
            let c: Int
            let d: Int
          }
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
