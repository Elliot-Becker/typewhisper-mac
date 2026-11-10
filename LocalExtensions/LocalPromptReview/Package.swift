// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "LocalPromptReview", platforms: [.macOS(.v14)], products: [.library(name: "ReviewChecks", targets: ["ReviewChecks"])], targets: [.target(name: "ReviewChecks"), .testTarget(name: "ReviewChecksTests", dependencies: ["ReviewChecks"])])
