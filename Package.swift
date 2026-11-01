// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PuffinTest",
    products: [
        .library(name: "PuffinTest", targets: ["PuffinTest"]),
        .executable(name: "puffintest-example", targets: ["PuffinTestExample"]),
    ],
    targets: [
        .target(name: "PuffinTest"),
        .executableTarget(name: "PuffinTestExample", dependencies: ["PuffinTest"]),
    ]
)
