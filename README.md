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
- [Troubleshooting](#troubleshooting)
- [Support](#support)
- [License](#license)

---

## Features

- 🔐 **Face ID & Touch ID Support** - Native iOS biometric authentication
- 📱 **iOS 12.0+ Compatible** - Wide device support
- 🎯 **Clean Public API** - Simple, intuitive interface
- ✅ **Protocol-Based Architecture** - Fully testable with dependency injection
- 🧵 **Thread-Safe** - All operations safely dispatched to main thread
- 🚀 **Swift Concurrency Compatible** - @Sendable closure support
- 📦 **Multiple Distribution** - SPM, CocoaPods
- 🔒 **Semantic Error Types** - Flexible error handling for UI
- 🛡️ **Access Control** - Internal classes protected from external access
- 🔐 **Optional Security Checks** - Runtime jailbreak/debugger detection (opt-in, disabled by default)

---

## Requirements

- **iOS:** 12.0+
- **Xcode:** 14.0+
- **Swift:** 5.7+
- **Dependencies:** None

---

## Installation

### CocoaPods

DefXBiometric is available through [CocoaPods](https://cocoapods.org). Add to your `Podfile`:

```ruby
platform :ios, '12.0'
use_frameworks!

target 'YourAppName' do
  pod 'DefXBiometric', '1.0.1'
end
```

Then run:

```bash
pod install --repo-update
```

**Important:** Always open the `.xcworkspace` file after installation, not the `.xcodeproj` file.

### Swift Package Manager

#### Via Xcode:
1. **File → Add Package Dependencies...**
2. Enter URL: `https://github.com/Definex-Mobile/iOS-BiometricAuth-SDK.git`
3. **Dependency Rule:** Up to Next Major Version `1.0.1`
4. Click **Add Package**

#### Via Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/Definex-Mobile/iOS-BiometricAuth-SDK.git", from: "1.0.1")
]
```

### Import SDK

```swift
import DefXBiometric
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
// Shared singleton instance (with default configuration)
public static let shared: DefXBiometricAuth

// Initialize with custom configuration
public init(configuration: DefXBiometricConfiguration = .default)

// Get available biometric type
public func availableBiometricType() -> BiometricType

// Check if biometric is available
public func isBiometricAvailable() -> Bool

// Authenticate user with optional security policy override
public func authenticate(
    reason: String = "Authenticate to continue",
    securityPolicy: SecurityPolicy? = nil,
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
    case notAvailable                       // Biometric not available
    case notEnrolled                        // No biometric enrolled
    case lockout                            // Too many failed attempts
    case cancelled                          // User cancelled
    case fallback                           // User chose fallback
    case authenticationFailed               // Wrong biometric
    case securityRiskDetected(SecurityRiskResult)  // Security risk blocked auth
    case systemError(String)                // System error
    case unknown                            // Unknown error
    
    // Stable identifier for localization
    public var identifier: String
}
```

---

## Configuration

### Biometrics-Only Mode

The SDK uses **biometrics-only policy** with no passcode fallback:

**Technical Implementation:**
- Uses `LAPolicy.deviceOwnerAuthenticationWithBiometrics`
- Sets `localizedFallbackTitle = ""` to hide system fallback button
- No "Enter Password" or "Use Passcode" button will appear in the biometric prompt

**Behavior:**
- Face ID/Touch ID authentication only
- User gets 2-3 biometric attempts (iOS handles retries automatically)
- If biometric fails, authentication is cancelled
- Apps **must** provide alternative authentication (e.g., password) when biometrics fail

**Why No Passcode Fallback?**
This design ensures:
- Clear separation between biometric and password authentication
- Apps have full control over fallback logic
- Better UX with consistent authentication flows

### Security Checks (Optional, Disabled by Default)

The SDK includes **opt-in runtime security checks** to detect potentially compromised environments:

**Available Detections:**
- **Jailbreak** - Device is jailbroken/rooted
- **Simulator** - Running on simulator (not physical device)
- **Debugger** - Debugger is attached to the process
- **Hooking** - Runtime injection detected (e.g., Frida, Cycript)

**Default Behavior:** Security checks are **disabled by default**. This ensures maximum compatibility and allows apps to authenticate in development/testing environments.

**Enabling Security Checks:**

```swift
// Option 1: Configure at initialization with strict policy
let secureAuth = DefXBiometricAuth(
    configuration: DefXBiometricConfiguration(securityPolicy: .strict)
)

secureAuth.authenticate(reason: "Secure login") { result in
    switch result {
    case .success:
        print("Authenticated successfully")
        
    case .failure(.securityRiskDetected(let riskResult)):
        print("Security risk detected: \(riskResult.detectedRisks)")
        // Handle security risk (e.g., show warning, block access)
        
    case .failure(let error):
        print("Authentication failed: \(error)")
    }
}

// Option 2: Override security policy per authentication call
DefXBiometricAuth.shared.authenticate(
    reason: "Sensitive operation",
    securityPolicy: .strict  // Override default
) { result in
    // Handle result
}

// Option 3: Use permissive policy (only blocks jailbreak/hooking)
let auth = DefXBiometricAuth(
    configuration: DefXBiometricConfiguration(securityPolicy: .permissive)
)
```

**Available Security Policies:**
- `.none` - No security checks (explicit)
- `.permissive` - Only blocks jailbreak and hooking
- `.strict` - Blocks all risks (jailbreak, simulator, debugger, hooking)
- Custom - Create your own: `SecurityPolicy(blockedRisks: [.jailbreak])`

**Important Notes:**
- Using `.strict` policy will block authentication on simulators and during debugging
- Use `.permissive` or custom policies for development/testing
- Security checks add minimal overhead (< 10ms)
- For production apps with sensitive operations, consider using `.strict` or `.permissive`

### Default Behavior

```swift
// Uses default reason: "Authenticate to continue"
// No security checks (default config)
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
    
case .securityRiskDetected(let riskResult):
    // Security risk detected (only if security policy enabled)
    print("Detected risks: \(riskResult.detectedRisks)")
    showSecurityAlert("Authentication blocked due to security concerns")
    
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

## Troubleshooting

### Build/Run Error: rsync "Operation not permitted"

If you encounter build errors related to `rsync`, `mkstempat`, or "Operation not permitted" during build:

**Solution:**

1. Open your app target in Xcode
2. Go to **Build Settings**
3. Search for **"User Script Sandboxing"**
4. Set **`ENABLE_USER_SCRIPT_SANDBOXING`** to **`NO`**

Additionally, try cleaning:

```bash
# Clean build folder in Xcode: Product → Clean Build Folder (⇧⌘K)

# Or delete DerivedData manually:
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### CocoaPods Web Interface Error

If you see "Internal Server Error" on the cocoapods.org website when searching for DefXBiometric, this is a temporary issue with the web interface and does not affect the SDK or installation.

**Verify SDK availability via Trunk:**

```bash
# Check pod info via Trunk
pod trunk info DefXBiometric

# Or use Trunk API directly
curl https://trunk.cocoapods.org/api/v1/pods/DefXBiometric
```

The SDK installs correctly via `pod install` regardless of web interface status.

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

**DefineX - Consulting, Technology & Labs**
- 🌐 Website: https://www.definex.com
- 📱 Mobile SDKs: https://github.com/Definex-Mobile

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

