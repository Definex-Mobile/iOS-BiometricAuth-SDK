# DefXBiometric iOS SDK

[![Swift Version](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2012.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen.svg)](https://cocoapods.org)

A production-ready, clean, and testable iOS Biometric Authentication SDK for Face ID and Touch ID.

---

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)
- [Security Notes](#security-notes)
- [Sample App](#sample-app)
- [Version History](#version-history)
- [Support](#support)
- [License](#license)

---

## Features

- 🔐 **Face ID & Touch ID Support** - Native iOS biometric authentication
- 📱 **iOS 12.0+ Compatible** - Wide device support
- 🎯 **Clean Public API** - Simple, intuitive interface
- ✅ **Protocol-Based Architecture** - Fully testable with dependency injection
- 🧵 **Thread-Safe** - All operations safely dispatched to main thread
- 🚀 **Swift 6 Concurrency Ready** - @Sendable closure support
- 📦 **Multiple Distribution** - SPM, CocoaPods
- 🔒 **Semantic Error Types** - Flexible error handling for UI
- 🛡️ **Access Control** - Internal classes protected from external access

---

## Requirements

- **iOS:** 12.0+
- **Xcode:** 14.0+
- **Swift:** 5.7+
- **Dependencies:** None

---

## Installation

### Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ekinbarisdmr/iOS-BiometricAuth-SDK.git", from: "1.0.1")
]
```

Or in Xcode:
1. **File → Add Package Dependencies...**
2. Enter URL: `https://github.com/ekinbarisdmr/iOS-BiometricAuth-SDK.git`
3. Select version: `1.0.1` or higher

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'DefXBiometric', :git => 'https://github.com/ekinbarisdmr/iOS-BiometricAuth-SDK.git', :tag => '1.0.1'
```

Then run:

```bash
pod install
```

---

## Quick Start

### 1. Configure Info.plist

Add Face ID usage description to your app's `Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We need to verify your identity using Face ID</string>
```

**Important Notes:**
- `NSFaceIDUsageDescription` is **required** by Apple for Face ID
- `NSCameraUsageDescription` is **NOT** needed (biometric auth doesn't use camera)
- Touch ID does not require usage description
- SDK cannot add this to Info.plist; host app must include it

### 2. Import SDK

```swift
import DefXBiometric
```

### 3. Check Biometric Availability

```swift
// Check which biometric type is available
let biometricType = DefXBiometricAuth.shared.availableBiometricType()

switch biometricType {
case .faceID:
    print("✅ Face ID is available")
case .touchID:
    print("✅ Touch ID is available")
case .none:
    print("❌ No biometric authentication available")
}

// Check if biometric can be used right now
if DefXBiometricAuth.shared.isBiometricAvailable() {
    print("✅ Biometric authentication is ready")
}
```

### 4. Authenticate User

```swift
DefXBiometricAuth.shared.authenticate(
    reason: "Authenticate to access your account"
) { result in
    switch result {
    case .success:
        print("✅ Authentication successful")
        // Navigate to authenticated screen
        
    case .failure(let error):
        switch error {
        case .cancelled:
            // User cancelled - handle gracefully
            break
            
        case .notAvailable, .notEnrolled:
            // Show alternative authentication
            showPasswordLogin()
            
        case .lockout:
            // Too many attempts - user must unlock device
            showLockoutAlert()
            
        case .systemError(let message):
            print("System error: \(message)")
            showPasswordLogin()
            
        default:
            showPasswordLogin()
        }
    }
}
```

---

## API Reference

### DefXBiometricAuth

Main entry point for biometric authentication.

```swift
// Shared singleton instance
public static let shared: DefXBiometricAuth

// Get available biometric type
public func availableBiometricType() -> BiometricType

// Check if biometric is available
public func isBiometricAvailable() -> Bool

// Authenticate user
public func authenticate(
    reason: String = "Authenticate to continue",
    fallbackTitle: String? = nil,  // Ignored (biometrics-only mode)
    completion: @escaping (Result<Void, BiometricError>) -> Void
)
```

### BiometricType

```swift
public enum BiometricType {
    case faceID    // Face ID available
    case touchID   // Touch ID available
    case none      // No biometric available
}
```

### BiometricError

```swift
public enum BiometricError: Error {
    case notAvailable        // Biometric not available
    case notEnrolled         // No biometric enrolled
    case lockout             // Too many failed attempts
    case cancelled           // User cancelled
    case fallback            // User chose fallback
    case systemError(String) // System error
    case unknown             // Unknown error
    
    // Stable identifier for localization
    public var identifier: String
}
```

---

## Configuration

### Biometrics-Only Mode

The SDK uses **biometrics-only policy** by default:
- Face ID/Touch ID authentication only
- No passcode fallback option shown
- `fallbackTitle` parameter is ignored
- Apps should provide alternative authentication (e.g., password) when biometrics fail

### Default Behavior

```swift
// Uses default reason: "Authenticate to continue"
DefXBiometricAuth.shared.authenticate { result in
    // Handle result
}

// Custom reason (recommended)
DefXBiometricAuth.shared.authenticate(
    reason: "Login to your account"
) { result in
    // Handle result
}
```

---

## Error Handling

```swift
switch error {
case .cancelled:
    // User cancelled - don't show error
    break
    
case .notAvailable, .notEnrolled:
    // Biometric not usable - show password
    showPasswordLogin()
    
case .lockout:
    // Guide user to unlock device
    showAlert("Too many attempts. Please unlock your device.")
    
case .systemError(let message):
    print("System error: \(message)")
    showPasswordLogin()
    
default:
    showPasswordLogin()
}
```

---

## Best Practices

### 1. Check Availability First

```swift
guard DefXBiometricAuth.shared.isBiometricAvailable() else {
    showPasswordLogin()
    return
}

DefXBiometricAuth.shared.authenticate(reason: "Login") { result in
    // Handle result
}
```

### 2. Provide Clear Reason Text

```swift
// ❌ BAD
authenticate(reason: "Authenticate")

// ✅ GOOD
authenticate(reason: "Authenticate to view your balance")
authenticate(reason: "Confirm payment of $50.00")
```

### 3. Always Provide Alternative Auth

Since the SDK operates in biometrics-only mode, always offer password/PIN login when biometric authentication is unavailable or fails.

### 4. Test on Real Device

Simulators support biometric testing, but always verify on real devices for accurate behavior and performance.

---

## Security

DefXBiometric uses iOS LocalAuthentication framework with system-level security:

- Biometric data stays in Secure Enclave
- SDK never accesses raw biometric data
- Thread-safe operations
- Completion callbacks always on main thread

**Recommended practices:**
- Use Keychain for sensitive data storage
- Implement certificate pinning in network layer
- Add runtime security checks as needed
- Consider XCFramework distribution for basic obfuscation

---

## Support

### Commercial Support

For licensing, custom features, or enterprise support:

**DefineX Technology Inc.**
- 📧 Email: ekin.demir@teamdefinex.com
- 🌐 Website: https://www.definex.com

### Issues & Contributions

- 🐛 Bug Reports: Open an issue with reproduction steps
- 💡 Feature Requests: Describe use case and expected behavior
- 🔧 Pull Requests: Contact us first for contribution guidelines

---

## License

**Proprietary / Commercial License**

Copyright © 2025 DefineX Technology Inc. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited. See [LICENSE](LICENSE) file for full terms.

For licensing inquiries: info@definex.com

---

**Made with ❤️ by DefineX Mobile Team**
