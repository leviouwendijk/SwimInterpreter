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
        .executable(
            name: "t_swiminterpreter",
            targets: ["SwimInterpreterTests"]
        ),
        // .executable(
        //     name: "swiminttest",
        //     targets: ["SwimInterpreterTestFlows"]
        // ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Testing.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "SwimInterpreter"
        ),
        .executableTarget(
            name: "SwimInterpreterTests",
            dependencies: [
                "SwimInterpreter",
                .product(name: "Testing", package: "Testing"),
            ],
            path: "Testing/SwimInterpreterTests"
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
