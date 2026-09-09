// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwimInterpreter",
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
