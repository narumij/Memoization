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
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                typealias ___C = ___MemoizationCache___a
                let params = ___C.params(b, c: c, d: dd)
                if let result = a_cache.withLock({ $0 [params]
                    }) {
                  return result
                }
                let r = ___body(b, c: c, d: dd)
                a_cache.withLock {
                    $0 [params] = r
                }
                return r
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
          }
          
          enum ___MemoizationCache___a: _HashableMemoizationCacheProtocol {
            @usableFromInline struct Parameters: Hashable {
              @usableFromInline let b: Int
              @usableFromInline let c: Int
              @usableFromInline let d: Int
              init(_ b: Int, c: Int, d dd: Int) {
                  self.b = b
                  self.c = c
                  self.d = dd
              }
            }
            @usableFromInline typealias Return = Int
            @usableFromInline typealias Instance = Standard
            @inlinable @inline(__always)
            static func params(_ b: Int, c: Int, d dd: Int) -> Parameters {
              Parameters(b, c: c, d: dd)
            }
            @inlinable @inline(__always)
            static func create() -> Instance {
              .init()
            }
          }
          
          let a_cache = Mutex(___MemoizationCache___a.create())
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
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                typealias ___C = ___MemoizationCache___a
                let params = ___C.params(b, c: c, d: dd)
                if let result = a_cache.withLock({ $0 [params]
                    }) {
                  return result
                }
                let r = ___body(b, c: c, d: dd)
                a_cache.withLock {
                    $0 [params] = r
                }
                return r
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
          }
          
          enum ___MemoizationCache___a: _HashableMemoizationCacheProtocol {
            @usableFromInline struct Parameters: Hashable {
              @usableFromInline let b: Int
              @usableFromInline let c: Int
              @usableFromInline let d: Int
              init(_ b: Int, c: Int, d dd: Int) {
                  self.b = b
                  self.c = c
                  self.d = dd
              }
            }
            @usableFromInline typealias Return = Int
            @usableFromInline typealias Instance = Standard
            @inlinable @inline(__always)
            static func params(_ b: Int, c: Int, d dd: Int) -> Parameters {
              Parameters(b, c: c, d: dd)
            }
            @inlinable @inline(__always)
            static func create() -> Instance {
              .init()
            }
          }
          
          let a_cache = Mutex(___MemoizationCache___a.create())
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
              func a(_ b: Int, c: Int, d dd: Int) -> Int {
                typealias ___C = ___MemoizationCache___a
                let params = ___C.params(b, c: c, d: dd)
                if let result = a_cache.withLock({ $0 [params]
                    }) {
                  return result
                }
                let r = ___body(b, c: c, d: dd)
                a_cache.withLock {
                    $0 [params] = r
                }
                return r
              }
              func ___body(_ b: Int, c: Int, d dd: Int) -> Int {
                return 0
              }
              return a(b, c: c, d: dd)
          }
          
          enum ___MemoizationCache___a: _ComparableMemoizationCacheProtocol {
            @usableFromInline typealias Parameters = (Int, c: Int, d: Int)
            @usableFromInline typealias Return = Int
            @usableFromInline typealias Instance = LRU
            @inlinable @inline(__always)
            static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
              a < b
            }
            @inlinable @inline(__always)
            static func params(_ b: Int, c: Int, d dd: Int)  -> Parameters {
              (b, c: c, d: dd)
            }
            @inlinable @inline(__always)
            static func create() -> Instance {
              .init(maxCount: 999)
            }
          }
          
          let a_cache = Mutex(___MemoizationCache___a.create())
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
