# XCoin Demo App

A demonstration iOS application for testing and showcasing [DefXBiometric](https://github.com/Definex-Mobile/iOS-BiometricAuth-SDK) SDK integration with security-first biometric authentication.

## What is this?

XCoin is a crypto portfolio demo app that integrates the DefXBiometric SDK to protect Portfolio access with biometric authentication (Face ID / Touch ID). The app demonstrates:

- Security policy enforcement (jailbreak, simulator, debugger, hooking detection)
- Biometric authentication flow with custom UI overlay
- Configurable security settings
- Both **SPM** and **CocoaPods** integration support

This is a **testing playground** for DefXBiometric SDK, not a production app.

---

## Requirements

- **Xcode 14.0+**
- **iOS 13.0+**
- **Device or Simulator** (with biometric capabilities for full testing)

---

## Project Files

The repository contains **one** Xcode project file: `XCoin.xcodeproj`. A duplicate `CoinX.xcodeproj` was removed during cleanup to avoid confusion.

## Installation

### Swift Package Manager (SPM)

The project is already configured to use DefXBiometric as a local SPM package.

1. Open `XCoin.xcodeproj`
2. The package reference points to `../DefXBiometric` (local path)
3. Build and run

If you need to add it manually:
- File → Add Package Dependencies → Add Local → Select `DefXBiometric` folder

### CocoaPods

1. Install CocoaPods if needed:
   ```bash
   sudo gem install cocoapods
   ```

2. In the `XCoin` directory, create/update `Podfile`:
   ```ruby
   platform :ios, '13.0'
   use_frameworks!

   target 'XCoin' do
     pod 'DefXBiometric', :path => '../DefXBiometric'
   end
   ```

3. Install:
   ```bash
   pod install
   ```

4. Open `XCoin.xcworkspace` (not `.xcodeproj`)

---

## How to Use

### 1. Launch App
- Run the app on a device or simulator
- Navigate through tabs: **Home**, **Market**, **Portfolio**, **Rewards**, **Profile**

### 2. Portfolio Authentication Flow

When you open the **Portfolio** tab (if biometric authentication is enabled):

1. **BiometricAuthOverlay** appears
2. SDK performs **security checks** (simulator, debugger, jailbreak, hooking)
   - ❌ If violation detected → Error shown → "Try Again" button
   - ✅ If security passes → Biometric prompt (Face ID/Touch ID)
3. **During authentication:**
   - 🔒 **Overlay is locked** → All buttons disabled, no user interaction allowed
   - Prevents dismissal while native biometric prompt is active
4. **Authentication result:**
   - ✅ **Success** → Green checkmark → "Confirm" → Dismiss overlay → Access portfolio
   - ❌ **Failure** → Red error → "Try Again" → Retry authentication
   - **Cancel** → Dismisses overlay → Routes to Security tab

### 3. Cancel Button Behavior

- **Disabled during authentication** (no-op while biometric prompt is active)
- **After authentication completes:** Cancel dismisses overlay and routes to Security tab
- User can disable biometric authentication in Security Settings

### 4. Security Settings

Navigate to the **Security** tab (or tap Cancel in Portfolio overlay).

**Navigation:** Uses UINavigationController with large title "Security Settings" at top-left.

**Available Options:**

| Setting                    | What it does                                              |
|----------------------------|-----------------------------------------------------------|
| Biometric Authentication   | Enable/disable biometric requirement for Portfolio access |
| Block Rooted Devices       | Prevent auth if jailbreak detected                        |
| Block Emulators            | Prevent auth if running on simulator                      |
| Block Hooked Devices       | Prevent auth if runtime hooking detected (Frida, Cycript) |
| Block Debuggable Apps      | Prevent auth if debugger attached                         |

Changes take effect immediately on next Portfolio access.

---

## Demo Videos

| Face ID (Real Device) | Touch ID (Simulator) |
| --- | --- |
| [▶️ Watch](https://github.com/user-attachments/assets/9d1547f8-fd03-4701-a1f0-631d545f9a11) | [▶️ Watch](https://github.com/user-attachments/assets/cef2411b-74a4-4384-b44a-e35693aedea0) |

---

## Security Tests

### Block Emulators (Simulator Detection)

**Setup:**
1. Enable "Block Emulators" in Security Settings
2. Run app on **iOS Simulator**
3. Open Portfolio tab

**Expected:**
- ❌ Authentication fails immediately (no biometric prompt)
- Error: `"Security risks detected: Simulator"`
- "Try Again" button appears

---

### Block Debuggable Apps (Debugger Detection)

**Setup:**
1. Enable "Block Debuggable Apps" in Security Settings
2. Run app from **Xcode** (debugger attached)
3. Open Portfolio tab

**Expected:**
- ❌ Authentication fails immediately
- Error: `"Security risks detected: Debugger"`
- "Try Again" button appears

---

### Block Rooted Devices / Block Hooked Devices

**Debug Mode Simulation:**

In `DEBUG` builds, the SDK simulates jailbreak/hooking detection for testing purposes:
- If "Block Rooted Devices" is enabled → SDK simulates jailbreak detection
- If "Block Hooked Devices" is enabled → SDK simulates hooking detection

**Setup:**
1. Enable "Block Rooted Devices" or "Block Hooked Devices"
2. Run in DEBUG mode
3. Open Portfolio tab

**Expected:**
- ❌ Authentication fails
- Error: `"Security risks detected: Jailbreak"` or `"Hooking"`

**Note:** In `RELEASE` builds, simulation is disabled; real detection is performed.

---

### Error Types

| Error Type               | Trigger                                      |
|--------------------------|----------------------------------------------|
| `securityRiskDetected`   | Policy violation (simulator, debugger, etc.) |
| `notAvailable`           | Biometric hardware not available             |
| `notEnrolled`            | No Face ID/Touch ID enrolled                 |
| `authenticationFailed`   | Wrong face/fingerprint                       |
| `cancelled`              | User cancelled biometric prompt              |
| `lockout`                | Too many failed attempts                     |

---

## Troubleshooting

### Build Fails: "Unable to find DefXBiometric"
- Ensure local package path is correct: `../DefXBiometric` (relative to `XCoin.xcodeproj`)
- Clean build folder: Product → Clean Build Folder
- Re-resolve packages: File → Packages → Reset Package Caches

### Biometric Prompt Not Showing
- Security check likely failed. Check overlay error message.
- Verify Security Settings: disable all blocks to test biometric flow only.

### "Biometric Not Available" Error
- **Simulator:** Ensure Face ID/Touch ID is enrolled:
  - Features → Face ID → Enrolled
- **Device:** Check Settings → Face ID & Passcode

### Overlay Doesn't Dismiss
- **Expected:** Overlay is locked during authentication (no dismiss allowed)
- **Cancel:** Only works after authentication completes; routes to Security tab

### Navigation Title Not Showing
- Security Settings uses navigation bar with large title
- Other tabs (Home, Portfolio) hide navigation bar

---

## Notes

- Demo/testing app, not production-ready
- Security settings stored in `UserDefaults`
- Portfolio data is mocked
- Overlay interaction locked during biometric authentication
- Cancel routes to Security tab for settings adjustment
- Single `.xcodeproj` in repository

---

## License

This demo app is part of the DefXBiometric SDK project. See [LICENSE](../DefXBiometric/LICENSE) for details.
