import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct MemoizeMacro: BodyMacro & PeerMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    if context.lexicalContext.first?.is(FunctionDeclSyntax.self) == true {
      // 関数内関数の場合
      return [
      ]
    } else if context.lexicalContext == [] {
      // ファイルスコープの場合
      return [
        """
        \(cache(funcDecl, node))
        let \(cacheName(funcDecl)) = Mutex(\(cacheTypeName(funcDecl)).create())
        """
      ]
    } else if isStaticFunction(funcDecl) {
      /// struct, class, actorでかつ、static
      return [
        """
        \(cache(funcDecl, node))
        static let \(cacheName(funcDecl)) = Mutex(\(cacheTypeName(funcDecl)).create())
        """
      ]
    } else {
      /// struct, class, actorでかつ、non static
      return [
        """
        \(cache(funcDecl, node))
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

    let initialize = maxCount(node) == nil ? "\(cacheTypeName(funcDecl)).Parameters" : ""
    
    if context.lexicalContext.first?.is(FunctionDeclSyntax.self) == true {
      // 関数内関数の場合
      return [
      """
      \(cache(funcDecl, node))
      var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
      \(functionBody(funcDecl, initialize: initialize))
      """
      ]
    }
    else if isStaticFunction(funcDecl) || context.lexicalContext == [] {
      // ファイルスコープまたはstaticの場合
      return [
      """
      \(functionBodyWithMutex(funcDecl, initialize: initialize))
      """
      ]
    } else {
      // non file, non staticの場合
      return [
      """
      \(functionBody(funcDecl, initialize: initialize))
      """
      ]
    }
  }
}

public struct MemoizeMacro2: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    let maxCount: String? = maxCount(node)

    return [
      """
      \(structParameters(paramsType(funcDecl), funcDecl.signature.parameterClause))
      var \(cacheName(funcDecl)): [\(paramsType(funcDecl)): \(returnType(funcDecl))] = [:]
      \(functionBodyWithLimit(paramsType(funcDecl).description, cacheName(funcDecl).text, maxCount, funcDecl))
      """
    ]
  }
}

func functionBodyWithLimit(
  _ parameters: String, _ storage: String, _ maxCount: String?, _ funcDecl: FunctionDeclSyntax
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
      let maxCount: Int? = \(raw: maxCount ?? "nil")
      let args = \(raw: parameters)(\(raw: params))
      if let result = \(raw: storage)[args] {
        return result
      }
      let r = body(\(raw: params))
      if let maxCount, \(raw: storage).count == maxCount {
        let i = \(raw: storage).startIndex
        \(raw: storage).remove(at: i)
      }
      \(raw: storage)[args] = r
      return r
    }
    func body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
}

func structParameters(_ name: TypeSyntax, _ parameterClause: FunctionParameterClauseSyntax)
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
      return "@usableFromInline let \(parameterName): \(type)"
    case (_, let firstName, _, let type):
      return "@usableFromInline let \(firstName.trimmed): \(type)"
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

func hashCache(_ funcDecl: FunctionDeclSyntax) -> CodeBlockItemSyntax {
  return """
    enum \(cacheTypeName(funcDecl)) {
      @usableFromInline \(structParameters("Parameters", funcDecl.signature.parameterClause))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = [Parameters:Return]
      @inlinable @inline(__always)
      static func create() -> Instance {
        [:]
      }
    }
    """
}

func treeCache(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> CodeBlockItemSyntax {
  let params = typeParameter(funcDecl)
  return """
    enum \(cacheTypeName(funcDecl)): _MemoizationProtocol {
      @usableFromInline typealias Parameters = (\(raw: params))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = LRU
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
        a < b
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init(maxCount: \(raw: limit ?? "Int.max"))
      }
    }
    """
}

func functionBodyWithMutex(_ funcDecl: FunctionDeclSyntax, initialize: String) -> CodeBlockItemSyntax {

  let cache: TokenSyntax = cacheName(funcDecl)
  let params = callParameters(funcDecl)
  
  return """
    func \(funcDecl.name)\(funcDecl.signature){
      let args = \(raw: initialize)(\(raw: params))
      if let result = \(cache).withLock({ $0[args] }) {
        return result
      }
      let r = ___body(\(raw: params))
      \(cache).withLock { $0[args] = r }
      return r
    }
    func ___body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
}

func functionBody(_ funcDecl: FunctionDeclSyntax, initialize: String) -> CodeBlockItemSyntax {

  let cache: TokenSyntax = cacheName(funcDecl)
  let params = callParameters(funcDecl)

  return """
    func \(funcDecl.name)\(funcDecl.signature){
      let args = \(raw: initialize)(\(raw: params))
      if let result = \(cache)[args] {
        return result
      }
      let r = ___body(\(raw: params))
      \(cache)[args] = r
      return r
    }
    func ___body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
}

func callParameters(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "\(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "\(firstName.trimmed): \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: ", ")
}

func typeParameter(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
    case (.wildcard,_,let type):
      return "\(type)"
    case (_,let firstName,let type):
      return "\(firstName.trimmed): \(type)"
    }
  }.joined(separator: ", ")
}

func cache(_ funcDecl: FunctionDeclSyntax,_ node: AttributeSyntax) -> CodeBlockItemSyntax {
  let maxCount: String? = maxCount(node)
  if let maxCount {
    return treeCache(funcDecl, maxCount: maxCount)
  } else {
    return hashCache(funcDecl)
  }
}

func cacheTypeName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "___MemoizationCache___\(raw: funcDecl.name.text)"
}

func cacheName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "\(raw: funcDecl.name.text)_cache"
}

func paramsType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  "\(raw: funcDecl.name.text)_parameters"
}

func returnType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  funcDecl.signature.returnClause?.type.trimmed ?? "Void"
}

func isStaticFunction(_ functionDecl: FunctionDeclSyntax) -> Bool {
  functionDecl.modifiers.contains { $0.name.text == "static" }
}

func maxCount(_ node: AttributeSyntax) -> String? {
  var maxCount: String?
  let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []
  for argument in arguments {
    if let label = argument.label?.text, label == "maxCount" {
      if let valueExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
        maxCount = valueExpr.literal.text
        break
      }
    }
  }
  return maxCount ?? (isLRU(node) ? "nil" : nil)
}

func isLRU(_ node: AttributeSyntax) -> Bool {
  node.description.lowercased().contains("lru")
}

@main
struct MemoizePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    MemoizeMacro.self,
    MemoizeMacro2.self,
  ]
}
