import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct StoredMemoizeMacro: BodyMacro & PeerMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }
    
    if context.lexicalContext.first?.is(FunctionDeclSyntax.self) == true {
      return [
        """
        #warning("Stored memoize macro can not use in function.")
        """
      ]
    }

    if context.lexicalContext == [] {
      // ファイルスコープの場合
      return [
        storedCache(funcDecl, node),
        """
        let \(cacheName(funcDecl)) = Mutex(\(cacheTypeName(funcDecl)).create())
        """
      ]
    } else if isStaticFunction(funcDecl) {
      // struct, class, actorでかつ、static
      return [
        storedCache(funcDecl, node),
        """
        static let \(cacheName(funcDecl)) = Mutex(\(cacheTypeName(funcDecl)).create())
        """
      ]
    } else {
      // 関数内関数の場合
      // struct, class, actorでかつ、non static
      return [
        storedCache(funcDecl, node),
        """
        var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
        """
      ]
    }
  }

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }
    
    if context.lexicalContext.first?.is(FunctionDeclSyntax.self) == true {
      return [
        "\(funcDecl.body?.statements ?? [])"
      ]
    }

    let initialize = maxCount(node) == nil ? "\(cacheTypeName(funcDecl)).Parameters" : ""
    
    if isStaticFunction(funcDecl) || context.lexicalContext == [] {
      // ファイルスコープまたはstaticの場合
      return []
      + functionBodyWithMutex(funcDecl, initialize: initialize)
    } else {
      // 関数内関数の場合
      // non file, non staticの場合
      return []
      + functionBody(funcDecl, initialize: initialize)
    }
  }
}

