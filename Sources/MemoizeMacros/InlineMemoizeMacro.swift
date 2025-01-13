import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

// swift-ac-memoizeと同じもの
public struct InlineMemoizeMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    if let maxCount = maxCount(node) {
      return inlineBodyLRU(funcDecl, maxCount: maxCount)
    } else {
      return inlineBodyStandard(funcDecl)
    }
  }
}

func inlineBodyLRU(_ funcDecl: FunctionDeclSyntax,maxCount: String?) -> [CodeBlockItemSyntax] {
  [
    """
    \(lruCache(funcDecl, maxCount: maxCount))
    """,
    """
    var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
    """
  ] +
  functionBody(funcDecl, initialize: "")
}

func inlineBodyStandard(_ funcDecl: FunctionDeclSyntax) -> [CodeBlockItemSyntax] {
  [
    """
    \(hashCache(funcDecl))
    """,
    """
    var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
    """
  ] +
  functionBody(funcDecl, initialize: "\(cacheTypeName(funcDecl)).Parameters")
}
