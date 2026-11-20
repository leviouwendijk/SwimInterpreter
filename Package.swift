// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwimInterpreter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwimInterpreter",
            targets: ["SwimInterpreter"]
        ),
        // .executable(
        //     name: "swiminttest",
        //     targets: ["SwimInterpreterTestFlows"]
        // ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwimInterpreter"
        ),
        // .executableTarget(
        //     name: "SwimInterpreterTestFlows",
        //     dependencies: [
        //         "SwimInterpreter",
        //     ]
        // ),
    ],
    swiftLanguageModes: [.v6]
)
