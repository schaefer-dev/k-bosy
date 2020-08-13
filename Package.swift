// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KBoSy",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "KBoSyLib",
            targets: ["KBoSy"]),
        .executable(name: "KBoSyExec", targets: ["KBoSy"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.5.0")
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "5.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "KBoSy", dependencies: ["SPMUtility", "Specification", "LTL", "Utils", "Automata"]),
        //.testTarget(name: "KBoSyTests", dependencies: ["KBoSy"]),
        .target(name: "LTL", dependencies: []),
        .target(name: "Specification", dependencies: ["LTL", "Automata"]),
        .target(name: "Utils", dependencies: ["LTL"]),
        .target(name: "Automata", dependencies: ["LTL", "Utils"]),
        .testTarget(name: "AutomataTests", dependencies: ["Automata"]),
        .testTarget(name: "IOTests", dependencies: ["Automata", "Specification"]),
        .testTarget(name: "KnowledgeSpecificTests", dependencies: ["Specification"]),
        .testTarget(name: "KBSCTests", dependencies: ["Automata", "KBoSy"])
    ]
)
