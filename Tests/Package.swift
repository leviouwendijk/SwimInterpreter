// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwimInterpreterTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
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
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "SwimInterpreterTests",
            dependencies: [
                .product(name: "SwimInterpreter", package: "SwimInterpreter"),
                .product(name: "Testing", package: "Testing"),
            ]
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
