import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MemoizeMacros)
  import MemoizeMacros

  fileprivate let testMacros: [String: Macro.Type] = [
    "StoredCache": StoredMemoizeMacro.self,
  ]
#endif

final class StoredMemoizeTests: XCTestCase {

  func testMacro() throws {
    #if canImport(MemoizeMacros)
      assertMacroExpansion(
        """
        func A() {
          @StoredCache
          func B(_ C: Int) -> Int {
            return 0
          }
        }
        """,
        expandedSource: """
        func A() {
          func B(_ C: Int) -> Int {
              return 0
          }

          #warning("Stored memoize macro can not use in function.")
        }
        """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
