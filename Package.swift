// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "Memoization",
  platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .macCatalyst(.v18)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Memoization",
      targets: ["Memoization"]
    ),
    .executable(
      name: "MemoizeClient",
      targets: ["MemoizeClient"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    .package(
      url: "https://github.com/narumij/swift-ac-collections",
      from: "0.1.30"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    // Macro implementation that performs the source transformation of a macro.
    .macro(
      name: "MemoizeMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    // Library that exposes a macro as part of its API, which is used in client programs.
    .target(
      name: "Memoization",
      dependencies: [
        "MemoizeMacros",
        .product(name: "AcCollections", package: "swift-ac-collections"),
      ],
      path: "Sources/Memoize"),

    // A client of the library, which is able to use the macro in its own code.
    .executableTarget(name: "MemoizeClient", dependencies: ["Memoization"]),

    // A test target used to develop the macro implementation.
    .testTarget(
      name: "MemoizeTests",
      dependencies: [
        "MemoizeMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),

    .target(
      name: "MemoizeCache",
      dependencies: [
        "MemoizeMacros",
        .product(name: "AcCollections", package: "swift-ac-collections"),
      ]),

    .testTarget(
      name: "MemoizeCacheTests",
      dependencies: [
        "MemoizeCache"
      ]
    ),
  ]
)
