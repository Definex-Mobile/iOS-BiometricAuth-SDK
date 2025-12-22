# CocoaPods Integration Guide

This guide explains how to use DefXBiometric SDK via CocoaPods.

## Local Pod Usage (Development)

For local development and testing before publishing to a remote repository.

### Step 1: Create or Update Podfile

In your iOS app project directory, create a `Podfile`:

```ruby
# Podfile

platform :ios, '12.0'
use_frameworks!

target 'YourAppName' do
  # Local pod - points to SDK directory
  pod 'DefXBiometric', :path => '../DefXBiometric'
end
```

**Important:** Adjust the `:path` based on your directory structure:
- Same parent directory: `'../DefXBiometric'`
- Different location: `'/Users/eknbrsdmr/Desktop/DefXBiometric'`

### Step 2: Install Pods

```bash
cd /path/to/your/app
pod install
```

### Step 3: Open Workspace

```bash
open YourAppName.xcworkspace
```

**Important:** Always use `.xcworkspace` file, NOT `.xcodeproj`

### Step 4: Import and Use

```swift
import DefXBiometric

// Use the SDK
DefXBiometricAuth.shared.authenticate(reason: "Login") { result in
    // Handle result
}
```

## Example Podfile for DefXBiometricExample App

Create this file at `/Users/eknbrsdmr/Desktop/DefXBiometricExample/Podfile`:

```ruby
platform :ios, '12.0'
use_frameworks!

target 'DefXBiometricExample' do
  pod 'DefXBiometric', :path => '../DefXBiometric'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

## Validating Podspec

Before publishing, validate the podspec:

```bash
cd /Users/eknbrsdmr/Desktop/DefXBiometric
pod spec lint DefXBiometric.podspec --allow-warnings
```

**Note:** For local-only validation:
```bash
pod lib lint DefXBiometric.podspec --allow-warnings
```

## Remote Repository Setup (Future)

When ready to publish to a Git repository:

### Step 1: Update Podspec Source

Edit `DefXBiometric.podspec`:

```ruby
spec.source = { 
  :git => 'https://github.com/DefineX/DefXBiometric.git', 
  :tag => "#{spec.version}" 
}
```

### Step 2: Tag and Push

```bash
git tag 1.0.0
git push origin 1.0.0
```

### Step 3: Update Podfile

Users will then use:

```ruby
pod 'DefXBiometric', '~> 1.0'
```

## Troubleshooting

### "Unable to find a specification for DefXBiometric"

**Solution:**
- Check the `:path` in Podfile is correct
- Verify `DefXBiometric.podspec` exists in the specified path
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
- Make sure you're opening `.xcworkspace`, not `.xcodeproj`
- Clean build: **Product → Clean Build Folder** (⇧⌘K)
- Delete `DerivedData`:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData
  ```

## Resource Bundle Access

CocoaPods handles resource bundles automatically. The SDK uses:

```swift
NSLocalizedString("key", bundle: .module, comment: "")
```

For CocoaPods, SPM's `Bundle.module` is replaced with the resource bundle.

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
└── YourApp.xcworkspace     # ⚠️ Open this!
```

## Updating Local Pod

When you make changes to DefXBiometric SDK:

```bash
cd /path/to/your/app
pod update DefXBiometric
```

Or force reinstall:
```bash
pod deintegrate
pod install
```

## Best Practices

1. ✅ Use `:path` for local development
2. ✅ Always open `.xcworkspace`
3. ✅ Commit `Podfile.lock` to version control
4. ✅ Add `Pods/` to `.gitignore`
5. ✅ Test with `pod lib lint` before publishing

