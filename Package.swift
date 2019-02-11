// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "CSVReader",
    products: [
        .library(name: "CSVReader", targets: ["CSVReader"]),
    ],
    dependencies: [
        .package(url: "../FileReader", .branch("master")),
    ],
    targets: [
        .target(name: "CSVReader", dependencies: ["FileReader"]),
        .testTarget(name: "CSVReaderTests", dependencies: ["CSVReader"]),
    ]
)
