Pod::Spec.new do |s|
  # MARK: - Basic Information
  s.name             = 'DefXBiometric'
  s.version          = '1.0.0'
  s.summary          = 'Production-ready iOS Biometric Authentication SDK for Face ID and Touch ID'
  s.description      = <<-DESC
    DefXBiometric is a clean, testable, and production-ready iOS SDK for biometric authentication.
    Supports Face ID and Touch ID with a simple, intuitive API. Protocol-based architecture ensures
    full testability. Thread-safe operations and Swift 6 concurrency ready.
  DESC

  # MARK: - Repository & License
  s.homepage         = 'https://github.com/Definex-Mobile/iOS-BiometricAuth-SDK'
  s.license          = { :type => 'Proprietary', :file => 'LICENSE' }
  s.author           = { 'DefineX Mobile' => 'ekin.demir@teamdefinex.com' }
  s.source           = { :git => 'https://github.com/Definex-Mobile/iOS-BiometricAuth-SDK.git', :tag => s.version.to_s }

  # MARK: - Platform
  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.7', '5.8', '5.9', '5.10']

  # MARK: - Source Files
  s.source_files = 'Sources/DefXBiometric/**/*.swift'

  # MARK: - Frameworks
  s.frameworks = 'Foundation', 'LocalAuthentication'

  # MARK: - Module
  s.module_name = 'DefXBiometric'
  s.requires_arc = true
end

