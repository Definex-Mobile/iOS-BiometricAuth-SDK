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
- **Dependencies:** None (pure iOS SDK)

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
        print("❌ Authentication failed: \(error.identifier)")
        
        switch error {
        case .cancelled:
            // User pressed cancel button - handle gracefully
            print("User cancelled authentication")
            
        case .fallback:
            // User chose fallback option (biometrics-only mode: won't occur)
            showPasswordLogin()
            
        case .notAvailable:
            // Biometric not available - show alternative auth
            showPasswordLogin()
            
        case .notEnrolled:
            // No biometric enrolled - guide user to Settings
            showSettingsAlert()
            
        case .lockout:
            // Too many failed attempts - user must unlock with passcode
            showLockoutAlert()
            
        case .systemError(let message):
            // System error occurred
            print("System error: \(message)")
            
        case .unknown:
            // Unknown error
            print("Unknown error occurred")
        }
    }
}
```

---

## Configuration

### Default Behavior

The SDK uses intelligent defaults:

```swift
// If reason is empty, SDK uses: "Authenticate to continue"
DefXBiometricAuth.shared.authenticate { result in
    // Handle result
}

// Custom reason (recommended for better UX)
DefXBiometricAuth.shared.authenticate(
    reason: "Login to your account"
) { result in
    // Handle result
}
```

### Biometrics-Only Mode

The SDK operates in **biometrics-only mode** by default:
- Uses `.deviceOwnerAuthenticationWithBiometrics` policy (Face ID/Touch ID only)
- No passcode fallback option shown in the authentication prompt
- `fallbackTitle` parameter is ignored and maintained only for API compatibility
- If biometrics fail, app should provide alternative authentication (e.g., password login)

### Singleton vs Instance

```swift
// Option 1: Use singleton (recommended for most cases)
DefXBiometricAuth.shared.authenticate(reason: "Login") { result in }

// Option 2: Create instance (useful for testing)
let auth = DefXBiometricAuth()
auth.authenticate(reason: "Login") { result in }
```

---

## API Reference

### DefXBiometricAuth

Main entry point for biometric authentication.

#### Properties

```swift
// Shared singleton instance
public static let shared: DefXBiometricAuth
```

#### Methods

```swift
// Get available biometric type
public func availableBiometricType() -> BiometricType

// Check if biometric authentication is available
public func isBiometricAvailable() -> Bool

// Perform authentication
public func authenticate(
    reason: String = "Authenticate to continue",
    fallbackTitle: String? = nil,  // Ignored in biometrics-only mode
    completion: @escaping (Result<Void, BiometricError>) -> Void
)
```

### BiometricType

Represents available biometric authentication types.

```swift
public enum BiometricType {
    case faceID    // Face ID is available
    case touchID   // Touch ID is available
    case none      // No biometric available
}
```

### BiometricError

Semantic error types for flexible UI handling.

```swift
public enum BiometricError: Error {
    case notAvailable        // Biometric not available on device
    case notEnrolled         // No biometric data enrolled
    case lockout             // Locked due to too many failed attempts
    case cancelled           // User cancelled authentication
    case fallback            // User chose fallback method
    case systemError(String) // System error occurred
    case unknown             // Unknown error
}
```

#### Error Identifier

```swift
// Get stable string identifier for localization
let identifier = error.identifier
// Returns: "biometric_error_not_available", etc.
```

---

## Best Practices

### 1. Always Check Availability First

```swift
guard DefXBiometricAuth.shared.isBiometricAvailable() else {
    // Show password login immediately
    showPasswordLogin()
    return
}

// Proceed with biometric auth
DefXBiometricAuth.shared.authenticate(reason: "Login") { result in
    // Handle result
}
```

### 2. Provide Clear Reason Text

```swift
// ❌ BAD - Generic text
authenticate(reason: "Authenticate")

// ✅ GOOD - Clear, specific context
authenticate(reason: "Authenticate to view your balance")
authenticate(reason: "Confirm payment of $50.00")
```

### 3. Handle All Error Cases

```swift
switch error {
case .cancelled:
    // User changed their mind - don't show error
    break
    
case .fallback:
    // User wants password - show login
    showPasswordLogin()
    
case .notAvailable, .notEnrolled:
    // Can't use biometric - show alternative
    showPasswordLogin()
    
case .lockout:
    // Guide user to unlock device
    showAlert("Too many attempts. Please unlock your device.")
    
case .systemError(let message):
    // Log for debugging
    print("System error: \(message)")
    showPasswordLogin()
    
case .unknown:
    // Fallback to password
    showPasswordLogin()
}
```

### 4. Don't Store Sensitive Data in UserDefaults

```swift
// ❌ BAD
UserDefaults.standard.set(password, forKey: "password")

// ✅ GOOD - Use Keychain for sensitive data
// (Future: DefXBiometric will provide KeychainManager)
```

### 5. Test on Real Device

Simulator supports biometric simulation, but always test on real device for:
- Touch ID sensor behavior
- Face ID with glasses/mask/lighting conditions
- Performance and UI responsiveness

---

## Security Notes

### Current Implementation

DefXBiometric focuses on **biometric authentication** with iOS system-level security:

- ✅ Uses iOS LocalAuthentication framework
- ✅ Biometric data stays in Secure Enclave
- ✅ SDK never accesses raw biometric data
- ✅ Thread-safe operations
- ✅ Swift 6 Sendable compliance

### Recommended Security Practices

1. **Certificate Pinning** - Implement in your network layer
2. **Code Obfuscation** - Use tools like SwiftShield (external)
3. **Binary Protection** - Distribute as XCFramework for basic obfuscation
4. **Runtime Checks** - Add your own security policy layer
5. **Secure Keychain** - Use `kSecAttrAccessControl` with biometric flags

---

## Sample App

### Local Testing

A test app is included for local development:

```bash
cd /path/to/DefXBiometricLocalTest
pod install
open DefXBiometricLocalTest.xcworkspace
```

**Features:**
- ✅ Face ID/Touch ID testing
- ✅ All error scenarios
- ✅ UI examples
- ✅ Best practices demonstration

**Note:** Test app uses local pod path (not published pod).

---

## Version History

### 1.0.1 (2025-12-18)

**Bug Fixes**

- ✅ Fixed CocoaPods `use_frameworks!` rsync/_CodeSignature permission errors
- ✅ Added `static_framework = true` to force static linking
- ✅ Disabled code signing on pod target to prevent embed issues
- ✅ Updated repository URLs to personal repo

### 1.0.0 (2025-01-XX)

**Initial Release**

- ✅ Face ID and Touch ID support
- ✅ iOS 12.0+ compatibility
- ✅ SPM, CocoaPods distribution
- ✅ Comprehensive error handling
- ✅ Thread-safe operations
- ✅ Swift 6 Sendable support
- ✅ Protocol-based testable architecture
- ✅ Default reason text fallback
- ✅ Public API access control

---

## Support

### Commercial Support

For commercial licensing, custom features, or enterprise support:

**DefineX Technology Inc.**
- 📧 Email: ekin.demir@teamdefinex.com
- 🌐 Website: https://www.definex.com
- 📱 Mobile SDKs: https://github.com/Definex-Mobile

### Issues & Contributions

- 🐛 **Bug Reports:** Open an issue with reproduction steps
- 💡 **Feature Requests:** Describe use case and expected behavior
- 🔧 **Pull Requests:** Contact us first for contribution guidelines

---

## License

**Proprietary / Commercial License**

Copyright © 2025 DefineX Technology Inc. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited. See [LICENSE](LICENSE) file for full terms.

For licensing inquiries: info@definex.com

---

**Made with ❤️ by DefineX Mobile Team**
