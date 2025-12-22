// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DefXBiometric",
    
    // MARK: - Default Localization
    defaultLocalization: "en",
    
    // MARK: - Platform Requirements
    platforms: [
        .iOS(.v12)
    ],
    
    // MARK: - Products
    products: [
        .library(
            name: "DefXBiometric",
            targets: ["DefXBiometric"]
        )
    ],
    
    // MARK: - Targets
    targets: [
        
        // Main SDK target
        .target(
            name: "DefXBiometric",
            path: "Sources/DefXBiometric"
        ),
        
        // Test target
        .testTarget(
            name: "DefXBiometricTests",
            
            // MARK: - Dependencies
            dependencies: [
                "DefXBiometric"
            ],
            path: "Tests/DefXBiometricTests"
        )
    ],
    
    // MARK: - Swift Language Version
    swiftLanguageVersions: [.v5]
)
