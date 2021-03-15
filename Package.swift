// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UPNPDeviceScanner",
    platforms: [.iOS(.v10), .macOS(.v10_12)],
    products: [
        .executable(
            name: "CommandLineTest",
            targets: ["CommandLineTest"]),
        .library(name: "UPNPDeviceScanner",
                 targets: ["UPNPDeviceScanner"])
    ],
    targets: [
        .target(
            name: "CommandLineTest",
            dependencies: ["UPNPDeviceScanner"]),
        .target(
            name: "SSDP",
            dependencies: []),
        .target(
            name: "UPNPDeviceScanner",
            dependencies: ["SSDP"]),
        .testTarget(
            name: "UPNPDeviceScannerTests",
            dependencies: ["UPNPDeviceScanner"]),
    ]
)
