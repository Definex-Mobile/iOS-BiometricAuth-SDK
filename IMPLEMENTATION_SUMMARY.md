# DefXBiometric Implementation Notes

Technical overview of DefXBiometric SDK architecture and implementation decisions.

---

## Architecture

### Public API

The SDK exposes three main components:

- **DefXBiometricAuth**: Main entry point with singleton pattern for authentication operations
- **BiometricType**: Enum representing available biometric types (`.faceID`, `.touchID`, `.none`)
- **BiometricError**: Semantic error types for flexible UI error handling

### Internal Implementation

Internal classes handle authentication logic and are not accessible to SDK consumers:

- **BiometricAuthenticator**: Manages LocalAuthentication framework interaction
- **BiometricCapabilityDetector**: Detects device biometric capabilities
- **LAContextProtocol**: Protocol abstraction for LAContext (enables unit testing)

All internal classes use `internal` access control and are isolated from public API surface.

---

## Biometrics-Only Policy

### Policy Used

The SDK uses `.deviceOwnerAuthenticationWithBiometrics` policy exclusively.

### What This Means

- **Face ID/Touch ID only**: No passcode fallback option presented
- **App-level fallback**: Apps must implement password/PIN authentication when biometrics fail

### Rationale

- Clear separation of concerns: biometrics for convenience, password for security
- Predictable user experience across all integrations
- Forces proper alternative authentication implementation

### API Implications

- `.fallback` error case can theoretically occur (though fallback button is hidden)
- Apps should handle `.notAvailable` and `.notEnrolled` by showing alternative auth

---

## Error Mapping

The SDK maps LAError codes to semantic BiometricError cases:

| LAError | BiometricError | Meaning |
|---------|----------------|---------|
| `.biometryNotAvailable` | `.notAvailable` | Device doesn't support biometrics |
| `.biometryNotEnrolled` | `.notEnrolled` | No Face ID/Touch ID enrolled |
| `.biometryLockout` | `.lockout` | Too many failed attempts |
| `.userCancel`, `.appCancel`, `.systemCancel` | `.cancelled` | Authentication cancelled |
| `.authenticationFailed` | `.authenticationFailed` | Biometric match failed |
| `.userFallback` | `.fallback` | User chose fallback (rare in biometrics-only mode) |
| Other errors | `.systemError(String)` or `.unknown` | System-level or unknown errors |

**Note:** iOS handles retry attempts (2-3 tries) within the native biometric prompt. The SDK does not implement additional retry logic.

---

## Thread Safety

### Main Thread Guarantee

All completion callbacks are dispatched to the main thread, ensuring safe UI updates:

```swift
DispatchQueue.main.async {
    completion(result)
}
```

### Completion-Once Protection

The SDK uses a lock-protected guard to ensure completion is called exactly once, even if LAContext's reply handler is invoked multiple times or concurrently.

---

## Default Values

### Default Reason Text

If no reason is provided or the reason is empty, the SDK uses:

**"Authenticate to continue"**

This provides a neutral English default. Apps should provide localized, context-specific reason text for better UX.

---

## Limitations

1. **No Passcode Fallback**: By design. Apps must implement password/PIN fallback when biometrics fail or are unavailable.

2. **No Keychain Integration**: The SDK only handles biometric authentication. Apps must handle secure credential storage separately.

3. **iOS Only**: Currently supports iOS 12.0+. Not available for macOS, watchOS, or tvOS.

---

## Requirements

- **iOS:** 12.0+
- **Swift:** 5.7+
- **Xcode:** 14.0+
- **Dependencies:** None (pure iOS SDK)

---

## Distribution

- Swift Package Manager (SPM)
- CocoaPods
- Manual integration (XCFramework compatible)

---

## Status

✅ **Production Ready**

- Clean, testable architecture
- Thread-safe implementation
- Comprehensive error handling
- Zero external dependencies
- Protocol-based design for testability
