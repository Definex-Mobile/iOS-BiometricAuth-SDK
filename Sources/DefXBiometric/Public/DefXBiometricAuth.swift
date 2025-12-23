import Foundation

/// Main entry point for biometric authentication operations.
/// Thread-safe interface for checking capabilities and performing authentication.
@available(iOS 11.0, macOS 10.13.2, *)
public final class DefXBiometricAuth {
    
    // MARK: - Properties
    
    private let capabilityDetector: BiometricCapabilityDetector
    private let authenticator: BiometricAuthenticator
    
    // Serial queue for thread-safe access
    private let queue = DispatchQueue(label: "com.definex.defxbiometric.auth.serial")
    
    // MARK: - Singleton
    
    /// Shared instance for convenient access
    public static let shared = DefXBiometricAuth()
    
    // MARK: - Initialization
    
    /// Creates a new instance of DefXBiometricAuth
    private init() {
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
        queue.sync {
            capabilityDetector.detectBiometricType()
        }
    }
    
    /// Checks if biometric authentication is available and enrolled.
    /// - Returns: `true` if biometric authentication can be used, `false` otherwise
    public func isBiometricAvailable() -> Bool {
        queue.sync {
            capabilityDetector.isBiometricAvailable()
        }
    }
    
    /// Performs biometric authentication.
    /// - Parameters:
    ///   - reason: Message shown to user in the authentication prompt
    ///   - completion: Called on main thread with authentication result
    public func authenticate(
        reason: String = "Authenticate to continue",
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        // Work on serial queue to keep internal state usage consistent
        queue.async { [capabilityDetector, authenticator] in
            let type = capabilityDetector.detectBiometricType()
            guard type != .none else {
                DispatchQueue.main.async {
                    completion(.failure(.notAvailable))
                }
                return
            }
            
            let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
            let reasonToUse = trimmed.isEmpty ? "Authenticate to continue" : trimmed
            
            authenticator.authenticate(
                reason: reasonToUse,
                completion: completion
            )
        }
    }
}

