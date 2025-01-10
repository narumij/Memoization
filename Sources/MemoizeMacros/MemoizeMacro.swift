import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
    guard let argument = node.arguments.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }

    return "(\(argument), \(literal: argument.description))"
  }
}

public struct MemoizeBodyMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    var limit: String?
    let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []
    for argument in arguments {
      if let label = argument.label?.text, label == "limit" {
        if let valueExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
          limit = valueExpr.literal.text
          break
        }
      }
    }

    return [
      """
      \(params("Params", funcDecl.signature.parameterClause))
      let maxCount: Int? = \(raw: limit ?? "nil")
      var storage: [Params:Int] = .init()
      \(body("Params","storage", "maxCount", funcDecl))
      """
    ]
  }
}

func body(
  _ parameters: String, _ storage: String, _ maxCount: String, _ funcDecl: FunctionDeclSyntax
) -> CodeBlockItemSyntax {
  let params = funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "\(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "\(firstName.trimmed): \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: ", ")
  return """
    func \(funcDecl.name)\(funcDecl.signature){
      let args = \(raw: parameters)(\(raw: params))
      if let result = \(raw: storage)[args] {
        return result
      }
      let r = body(\(raw: params))
      if let \(raw: maxCount), \(raw: storage).count == \(raw: maxCount) {
        \(raw: storage).remove(at: \(raw: storage).indices.randomElement()!)
      }
      \(raw: storage)[args] = r
      return r
    }
    func body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
}

func params(_ name: TypeSyntax, _ parameterClause: FunctionParameterClauseSyntax)
  -> CodeBlockItemSyntax
{

  let inits = parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "self.\(parameterName) = \(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "self.\(firstName.trimmed) = \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: "\n")

  let members = parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName, $0.type) {
    case (.wildcard, _, .some(let parameterName), let type):
      return "let \(parameterName): \(type)"
    case (_, let firstName, _, let type):
      return "let \(firstName.trimmed): \(type)"
    }
  }.joined(separator: "\n")

  return """
    struct \(name): Hashable {
      init\(parameterClause){
        \(raw: inits)
      }
      \(raw: members)
    }
    """
}

func decoratorStruct(_ name: String, _ funcDecl: FunctionDeclSyntax) -> CodeBlockItemSyntax {
  return """
    struct \(raw: name) {
      mutating func cachClear(keepingCapacity flag: Bool = false) {
        memo.removeAll(keepingCapacity: flag)
      }
      func cacheInfo() -> [Parameters:Int] {
        memo
      }
      \(params("Parameters", funcDecl.signature.parameterClause))
      typealias Return = \(funcDecl.signature.returnClause?.type ?? "Void")
      var memo: [Parameters:Int] = .init()
      let maxCount: Int? = nil
      func \(funcDecl.name)\(funcDecl.signature){
        \(body("Parameters","memo", "maxCount", funcDecl))
      }
    }
    """
}

func decoratorClass(_ name: String, _ funcDecl: FunctionDeclSyntax) -> CodeBlockItemSyntax {
  return """
    class \(raw: name) {
      func cachClear(keepingCapacity flag: Bool = false) {
        memo.removeAll(keepingCapacity: flag)
      }
      func cacheInfo() -> [Parameters:Int] {
        memo
      }
      \(params("Parameters", funcDecl.signature.parameterClause))
      typealias Return = \(funcDecl.signature.returnClause?.type ?? "Void")
      var memo: [Parameters:Int] = .init()
      let maxCount: Int? = nil
      func \(funcDecl.name)\(funcDecl.signature){
        \(body("Parameters","memo", "maxCount", funcDecl))
      }
    }
    """
}

func cacheName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "\(raw: funcDecl.name.text)_cache"
}

func paramsType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {

//  let types = funcDecl.signature
//    .parameterClause.parameters
//    .map {
//      if $0.firstName.tokenKind == .wildcard {
//        "\($0.type.trimmed)"
//      } else {
//        "\($0.firstName.trimmed)_\($0.type.trimmed)"
//      }
//    }
//    .joined(separator: "_")

  return "\(raw: funcDecl.name.text)_parameters"
}

func returnType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  funcDecl.signature.returnClause?.type.trimmed ?? "Void"
}

public enum PeerValueWithSuffixNameMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }
    return [
      """
      var \(cacheName(funcDecl)): [\(paramsType(funcDecl)): \(returnType(funcDecl))] = [:]
      """,
      "\(params(paramsType(funcDecl), funcDecl.signature.parameterClause))",
    ]
  }
}

func isStaticFunction(_ functionDecl: FunctionDeclSyntax) -> Bool {
  // 修飾子 (modifiers) を確認
  for modifier in functionDecl.modifiers {
    if modifier.name.text == "static" {
      return true
    }
  }
  return false
}

func isGlobalScope(functionDecl: FunctionDeclSyntax) -> Bool {
    // 親ノードをたどって確認
    var parent = functionDecl.parent
    while let current = parent {
        if current.is(SourceFileSyntax.self) {
            // 親が SourceFileSyntax ならグローバルスコープ
            return true
        }
        // 親ノードをたどる
        parent = current.parent
    }
    return false
}

public struct MemoizeBodyMacro2: BodyMacro & PeerMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }
    
    var isGlobal = funcDecl.parent == nil || funcDecl.parent?.is(SourceFileSyntax.self) == true
    var isStatic = isStaticFunction(funcDecl)

    var isolated = (isGlobal || isStatic) ? "nonisolated(unsafe)" : nil
    var staticDecl = isStatic ? "static" : nil
    
    var modifiers = [isolated, staticDecl].compactMap{ $0 }.joined(separator: " ")
    
    return [
      """
      \(raw: modifiers) var \(cacheName(funcDecl)): [\(paramsType(funcDecl)): \(returnType(funcDecl))] = [:]
      """,
      "\(params(paramsType(funcDecl), funcDecl.signature.parameterClause))",
    ]
  }

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    var limit: String?
    let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []
    for argument in arguments {
      if let label = argument.label?.text, label == "maxCount" {
        if let valueExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
          limit = valueExpr.literal.text
          break
        }
      }
    }

    return [
      """
      let maxCount: Int? = \(raw: limit ?? "nil")
      \(body(paramsType(funcDecl).description,cacheName(funcDecl).text, "maxCount", funcDecl))
      """
    ]
  }
}

@main
struct MemoizePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    StringifyMacro.self,
    MemoizeBodyMacro.self,
    MemoizeBodyMacro2.self,
  ]
}
