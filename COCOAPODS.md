# CocoaPods Integration Guide

Complete guide for integrating DefXBiometric SDK via CocoaPods.

---

## Installation

### Step 1: Create or Update Podfile

In your iOS app project directory, create or edit `Podfile`:

```ruby
# Podfile

platform :ios, '12.0'
use_frameworks!

target 'YourAppName' do
  # From Git repository (recommended)
  pod 'DefXBiometric', :git => 'https://github.com/ekinbarisdmr/iOS-BiometricAuth-SDK.git', :tag => '1.0.1'
  
  # Or use local path for development
  # pod 'DefXBiometric', :path => '../DefXBiometric'
end
```

**Path Options:**
- **Git repository**: `:git => 'URL', :tag => 'VERSION'`
- **Local development**: `:path => '../DefXBiometric'` or `:path => '/path/to/DefXBiometric'`

### Step 2: Install Pods

```bash
pod install
```

### Step 3: Open Workspace

```bash
open YourAppName.xcworkspace
```

**Important:** Always use `.xcworkspace` file, NOT `.xcodeproj`

---

## Usage

### Import and Authenticate

```swift
import DefXBiometric

// Check availability
if DefXBiometricAuth.shared.isBiometricAvailable() {
    // Authenticate
    DefXBiometricAuth.shared.authenticate(reason: "Login to your account") { result in
        switch result {
        case .success:
            print("✅ Authentication successful")
        case .failure(let error):
            print("❌ Authentication failed: \(error)")
        }
    }
}
```

---

## Troubleshooting

### "Unable to find a specification for DefXBiometric"

**Solution:**
- Verify `:git` URL or `:path` is correct
- Ensure `DefXBiometric.podspec` exists in the path
- Run `pod install --repo-update`

### Build Errors After Pod Install

**Solution:**

```bash
pod deintegrate
pod install
```

### "The sandbox is not in sync with the Podfile.lock"

**Solution:**

```bash
pod install
```

### Module 'DefXBiometric' not found

**Solution:**
- Open `.xcworkspace`, not `.xcodeproj`
- Clean build: **Product → Clean Build Folder** (⇧⌘K)
- Delete DerivedData:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData
  ```

### CocoaPods Code Signing Issues

If you encounter `_CodeSignature` or rsync permission errors:

```ruby
# Add to Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

---

## Updating the SDK

### Update to Latest Version

```bash
pod update DefXBiometric
```

### Force Reinstall

```bash
pod deintegrate
pod install
```

---

## Local Development

For local SDK development, use path-based pod:

```ruby
# Podfile
pod 'DefXBiometric', :path => '../DefXBiometric'
```

After making changes to the SDK:

```bash
pod update DefXBiometric
```

---

## Best Practices

1. ✅ Always open `.xcworkspace` after pod install
2. ✅ Commit `Podfile.lock` to version control
3. ✅ Add `Pods/` to `.gitignore`
4. ✅ Use specific version tags for production
5. ✅ Use local path only for development

---

## Directory Structure

After `pod install`:

```
YourApp/
├── Podfile
├── Podfile.lock
├── Pods/
│   ├── DefXBiometric/        # SDK source
│   └── ...
├── YourApp.xcodeproj
└── YourApp.xcworkspace       # ⚠️ Open this!
```

---

## Support

For issues or questions:

**DefineX Technology Inc.**
- 📧 Email: ekin.demir@teamdefinex.com
- 🌐 Website: https://www.definex.com
