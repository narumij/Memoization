import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MemoizeMacros)
import MemoizeMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "Memoize": MemoizeBodyMacro.self,
    "AddMemoized_peer": PeerValueWithSuffixNameMacro.self,
    "AddMemoized_body": MemoizeBodyMacro2.self,
]
#endif

final class MemoizeTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MemoizeMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MemoizeMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
  
  func testMacro1() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        @Memoize
        func test(_ a: Int) -> Int {
          if a == 10 {
            return 10
          }
          return a + test(a - 1)
        }
        """,
        expandedSource: """
          func test(_ a: Int) -> Int {
              struct Params: Hashable {
                init(_ a: Int) {
                  self.a = a
                }
                let a: Int
              }
              let maxCount: Int? = nil
              var storage: [Params:Int] = .init()
              func test(_ a: Int) -> Int {
                let args = Params(a)
                if let result = storage[args] {
                  return result
                }
                let r = body(a)
                if let maxCount, storage.count == maxCount {
                  storage.remove(at: storage.indices.randomElement()!)
                }
                storage[args] = r
                return r
              }
              func body(_ a: Int) -> Int {
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
        @Memoize
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
              struct Params: Hashable {
                init(_ x: Int, y yy: Int, z: Int) {
                  self.x = x
                  self.y = yy
                  self.z = z
                }
                let x: Int
                let y: Int
                let z: Int
              }
              let maxCount: Int? = nil
              var storage: [Params:Int] = .init()
              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                let args = Params(x, y: yy, z: z)
                if let result = storage[args] {
                  return result
                }
                let r = body(x, y: yy, z: z)
                if let maxCount, storage.count == maxCount {
                  storage.remove(at: storage.indices.randomElement()!)
                }
                storage[args] = r
                return r
              }
              func body(_ x: Int, y yy: Int, z: Int) -> Int {
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
  
//  func testPeerMacro() throws {
//      #if canImport(MemoizeMacros)
//      assertMacroExpansion(
//          """
//          @AddMemoized_peer
//          func a(_ b: Int, c: Int, d dd: Int) -> Int {
//            return 0
//          }
//          """,
//          expandedSource: """
//          func a(_ b: Int, c: Int, d dd: Int) -> Int {
//            return 0
//          }
//          
//          var _a_cache: [_Func_a_params_Int_c_Int_d_Int: Int] = [:]
//          
//          struct _Func_a_params_Int_c_Int_d_Int: Hashable {
//            init(_ b: Int, c: Int, d dd: Int) {
//              self.b = b
//              self.c = c
//              self.d = dd
//            }
//            let b: Int
//            let c: Int
//            let d: Int
//          }
//          """,
//          macros: testMacros
//      )
//      #else
//      throw XCTSkip("macros are only supported when running tests for the host platform")
//      #endif
//  }
  
  func testBodyMacro() throws {
      #if canImport(MemoizeMacros)
      assertMacroExpansion(
          """
          @AddMemoized_body
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
}
