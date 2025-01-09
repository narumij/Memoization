import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
@_spi(Testing) import SwiftSyntaxMacroExpansion

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
    
    let funcBaseName = funcDecl.name.text
    let functionSignature = funcDecl.signature
    let codeBlock = funcDecl.body

    let params = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
      case (.wildcard,_,.some(let parameterName)):
        return "\(parameterName)"
      case (_,let firstName,.some(let parameterName)):
        return "\(firstName.trimmed): \(parameterName)"
      case (_,_,.none):
        fatalError()
      }
    }.joined(separator: ", ")

    let inits = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
      case (.wildcard,_,.some(let parameterName)):
        return "self.\(parameterName) = \(parameterName)"
      case (_,let firstName,.some(let parameterName)):
        return "self.\(firstName.trimmed) = \(parameterName)"
      case (_,_,.none):
        fatalError()
      }
    }.joined(separator: "\n")

    let members = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName, $0.type) {
      case (.wildcard,_,.some(let parameterName),let type):
        return "let \(parameterName): \(type)"
      case (_,let firstName,_,let type):
        return "let \(firstName.trimmed): \(type)"
      }
    }.joined(separator: "\n")

    return [
            """
            struct Params: Hashable {
              init\(funcDecl.signature.parameterClause){
                \(raw: inits)
              }
              \(raw: members)
            }
            let maxCount: Int? = \(raw: limit ?? "nil")
            var storage: [Params:Int] = .init()
            func \(raw: funcBaseName)\(functionSignature){
              let args = Params(\(raw: params))
              if let result = storage[args] {
                return result
              }
              let r = body(\(raw: params))
              if let maxCount, storage.count == maxCount {
                storage.remove(at: storage.indices.randomElement()!)
              }
              storage[args] = r
              return r
            }
            func body\(functionSignature)\(codeBlock)
            return \(raw: funcBaseName)(\(raw: params))
            """
    ]
  }
}

@main
struct MemoizePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        MemoizeBodyMacro.self,
    ]
}
