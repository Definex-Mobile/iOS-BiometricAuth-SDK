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
  pod 'DefXBiometric', '1.0.1'
end
```

**Note:** DefXBiometric is published on [CocoaPods Trunk](https://cocoapods.org/pods/DefXBiometric). No need to specify git URL or path.

### Step 2: Install Pods

```bash
pod install --repo-update
```

This command will:
- Update your local CocoaPods specs repository
- Download and integrate DefXBiometric SDK
- Generate `.xcworkspace` file

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

```bash
pod install --repo-update
```

If still failing, manually update CocoaPods repository:

```bash
pod repo update
pod install
```

### Build/Run Error: rsync "Operation not permitted"

If you encounter errors like:
- `rsync: mkstemp "..." failed: Operation not permitted`
- Build phase script execution errors
- Permission denied during build

**Solution:**

1. Open your app target in Xcode
2. Go to **Build Settings**
3. Search for **"User Script Sandboxing"**
4. Set **`ENABLE_USER_SCRIPT_SANDBOXING`** to **`NO`**

Then clean and rebuild:

```bash
# In Xcode: Product → Clean Build Folder (⇧⌘K)

# Or delete DerivedData:
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Build Errors After Pod Install

**Solution:**

```bash
pod deintegrate
pod install --repo-update
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

---

## Updating the SDK

### Update to Specific Version

Edit your `Podfile` to specify the new version:

```ruby
pod 'DefXBiometric', '1.1.0'  # Update version number
```

Then run:

```bash
pod install --repo-update
```

### Update to Latest Available Version

Change your Podfile to use version specifier:

```ruby
pod 'DefXBiometric', '~> 1.0'  # Latest 1.x version
```

Then run:

```bash
pod update DefXBiometric --repo-update
```

### Force Reinstall

```bash
pod deintegrate
pod install --repo-update
```

---

## Best Practices

1. ✅ Always open `.xcworkspace` after pod install
2. ✅ Commit `Podfile.lock` to version control
3. ✅ Add `Pods/` to `.gitignore`
4. ✅ Use specific version numbers for production (`pod 'DefXBiometric', '1.0.1'`)
5. ✅ Run `pod install --repo-update` to ensure latest specs

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
