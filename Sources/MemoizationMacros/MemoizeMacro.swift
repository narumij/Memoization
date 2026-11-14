import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MemoizeMacro {}

struct MemoizeError: Error, CustomStringConvertible {
  let description: String
}

extension MemoizeMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    let f = try Function(declaration)
    return [
      "var cache = \(raw: f.name)Cache<Dictionary>()",
      "return \(raw: f.name)(\(raw: (f.arguments + ["cache: &cache"]).joined(separator: ", ")))",
    ]
  }
}

extension MemoizeMacro: PeerMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let f = try Function(declaration)
    let arguments = f.arguments.joined(separator: ", ")
    let cacheType = "some MemoCache<\(f.keyType), \(f.returnType)> & ~Copyable"
    let outerParameters = (f.parameters + ["cache: inout \(cacheType)"]).joined(separator: ", ")
    let innerSignature = "(\(f.parameters.joined(separator: ", "))) -> \(f.returnType)"
    return [
      "\(raw: f.modifiers)typealias \(raw: f.name)Cache<Storage: MemoCache & ~Copyable> = Storage where Storage.Key == \(raw: f.keyType), Storage.Value == \(raw: f.returnType)",
      """
      \(raw: f.modifiers)func \(raw: f.name)(\(raw: outerParameters)) -> \(raw: f.returnType) {
        func \(raw: f.name)\(raw: innerSignature) {
          let key = \(raw: f.keyExpression)
          if let r = cache[key] {
            return r
          }
          let r = body(\(raw: arguments))
          cache[key] = r
          return r
        }
        func body\(raw: innerSignature) \(f.body)
        return \(raw: f.name)(\(raw: arguments))
      }
      """
    ]
  }
}

extension Function {
  var keyType: String {
    switch keyTypes.count {
    case 1: keyTypes[0]
    case 2...4: "MemoizePack\(keyTypes.count)<\(keyTypes.joined(separator: ", "))>"
    default: "MemoizePack<\(keyTypes.joined(separator: ", "))>"
    }
  }
  var keyExpression: String {
    switch names.count {
    case 1: names[0]
    case 2...4: "MemoizePack\(names.count)(\(names.joined(separator: ", ")))"
    default: "MemoizePack(\(names.joined(separator: ", ")))"
    }
  }
}

/// The parts of a function declaration that the macro needs.
struct Function {
  let name: String
  let modifiers: String
  /// Parameters as declared (`x: Int`, `_ n: Int`, and so on)
  let parameters: [String]
  /// Arguments for a call (`x: x`, `n`, and so on)
  let arguments: [String]
  /// Parameter names used inside the function
  let names: [String]
  let keyTypes: [String]
  let returnType: String
  let body: CodeBlockSyntax

  init(_ declaration: some DeclSyntaxProtocol) throws {
    guard let decl = declaration.as(FunctionDeclSyntax.self) else {
      throw MemoizeError(description: "@Memoize can only be applied to a function")
    }
    let signature = decl.signature
    guard signature.effectSpecifiers == nil else {
      throw MemoizeError(description: "@Memoize does not support async or throws")
    }
    guard decl.genericParameterClause == nil else {
      throw MemoizeError(description: "@Memoize does not support generic functions")
    }
    guard let returnType = signature.returnClause?.type.trimmed else {
      throw MemoizeError(description: "@Memoize requires a return type")
    }
    guard let body = decl.body else {
      throw MemoizeError(description: "@Memoize requires a body")
    }
    let params = Array(signature.parameterClause.parameters)
    guard !params.isEmpty else {
      throw MemoizeError(description: "@Memoize requires at least one parameter")
    }
    // inout・some/any・可変長はキーにできない
    for p in params
    where p.ellipsis != nil || p.type.is(AttributedTypeSyntax.self) || p.type.is(SomeOrAnyTypeSyntax.self) {
      throw MemoizeError(description: "@Memoize does not support parameter type '\(p.type.trimmed)'")
    }

    self.name = decl.name.text
    self.modifiers = decl.modifiers.map { "\($0.trimmed) " }.joined()
    self.parameters = params.map { p in
      var p = p.trimmed
      p.trailingComma = nil
      return p.description
    }
    self.names = params.map { ($0.secondName ?? $0.firstName).text }
    self.arguments = params.map { p in
      let local = (p.secondName ?? p.firstName).text
      return p.firstName.tokenKind == .wildcard ? local : "\(p.firstName.text): \(local)"
    }
    self.keyTypes = params.map { $0.type.trimmedDescription }
    self.returnType = returnType.description
    self.body = body.trimmed
  }
}

@main
struct MemoizationPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [MemoizeMacro.self]
}
