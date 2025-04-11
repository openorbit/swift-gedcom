// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gedcom",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Gedcom",
            targets: ["Gedcom"]),
    ],
    dependencies: [
      .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Gedcom",
            dependencies: ["ZIPFoundation"]
        ),
        .testTarget(
            name: "GedcomTests",
            dependencies: ["Gedcom"],
            resources: [.copy("Gedcom7")]
        ),
    ]
)
