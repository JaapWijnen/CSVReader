// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CSVReader",
    products: [
        .library(name: "CSVReader", targets: ["CSVReader"]),
    ],
    dependencies: [
        .package(url: "git@github.com:JaapWijnen/FileReader.git", .branch("master")),
    ],
    targets: [
        .target(name: "CSVReader", dependencies: ["FileReader"]),
        .testTarget(name: "CSVReaderTests", dependencies: ["CSVReader"]),
    ]
)
