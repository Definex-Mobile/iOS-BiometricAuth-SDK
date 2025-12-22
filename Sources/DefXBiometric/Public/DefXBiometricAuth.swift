import Foundation

/// Main entry point for biometric authentication operations.
/// Thread-safe interface for checking capabilities and performing authentication.
@available(iOS 11.0, macOS 10.13.2, *)
public final class DefXBiometricAuth {
    
    // MARK: - Properties
    
    private let capabilityDetector: BiometricCapabilityDetector
    private let authenticator: BiometricAuthenticator
    
    // Lock for thread-safe access to public methods
    private let lock = NSLock()
    
    // MARK: - Singleton
    
    /// Shared instance for convenient access
    public static let shared = DefXBiometricAuth()
    
    // MARK: - Initialization
    
    /// Creates a new instance of DefXBiometricAuth
    public init() {
        self.capabilityDetector = BiometricCapabilityDetector()
        self.authenticator = BiometricAuthenticator()
    }
    
    /// Internal initializer for dependency injection in tests.
    internal init(
        capabilityDetector: BiometricCapabilityDetector,
        authenticator: BiometricAuthenticator
    ) {
        self.capabilityDetector = capabilityDetector
        self.authenticator = authenticator
    }
    
    // MARK: - Public API
    
    /// Returns the type of biometric authentication available on the device.
    /// - Returns: The biometric type (faceID, touchID, or none)
    public func availableBiometricType() -> BiometricType {
        lock.lock()
        defer { lock.unlock() }
        return capabilityDetector.detectBiometricType()
    }
    
    /// Checks if biometric authentication is available and enrolled.
    /// - Returns: `true` if biometric authentication can be used, `false` otherwise
    public func isBiometricAvailable() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return capabilityDetector.isBiometricAvailable()
    }
    
    /// Performs biometric authentication.
    /// - Parameters:
    ///   - reason: Message shown to user in the authentication prompt
    ///   - fallbackTitle: Custom fallback button title (ignored in biometrics-only mode)
    ///   - completion: Called on main thread with authentication result
    public func authenticate(
        reason: String = "Authenticate to continue",
        fallbackTitle: String? = nil,
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        lock.lock()
        
        let type = capabilityDetector.detectBiometricType()
        guard type != .none else {
            lock.unlock()
            completion(.failure(.notAvailable))
            return
        }
        
        let reasonToUse = reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Authenticate to continue"
            : reason
        
        authenticator.authenticate(
            reason: reasonToUse,
            fallbackTitle: fallbackTitle,
            completion: completion
        )
        
        lock.unlock()
    }
}

