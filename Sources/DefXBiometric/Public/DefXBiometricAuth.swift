import Foundation

/// Main entry point for biometric authentication operations.
/// Thread-safe interface for checking capabilities and performing authentication.
@available(iOS 11.0, macOS 10.13.2, *)
public final class DefXBiometricAuth {
    
    // MARK: - Properties
    
    private let configuration: DefXBiometricConfiguration
    private let capabilityDetector: BiometricCapabilityDetector
    private let authenticator: BiometricAuthenticator
    private let securityRiskDetector: SecurityRiskDetector
    
    // Serial queue for thread-safe access
    private let queue = DispatchQueue(label: "com.definex.defxbiometric.auth.serial")
    
    // MARK: - Singleton
    
    /// Shared instance with default configuration (no security checks)
    public static let shared = DefXBiometricAuth(configuration: .default)
    
    // MARK: - Initialization
    
    /// Creates a new instance of DefXBiometricAuth
    /// - Parameter configuration: Configuration for the SDK (default: .default with no security checks)
    public init(configuration: DefXBiometricConfiguration = .default) {
        self.configuration = configuration
        self.capabilityDetector = BiometricCapabilityDetector()
        self.authenticator = BiometricAuthenticator()
        self.securityRiskDetector = SecurityRiskDetector()
    }
    
    /// Internal initializer for dependency injection in tests.
    internal init(
        configuration: DefXBiometricConfiguration = .default,
        capabilityDetector: BiometricCapabilityDetector,
        authenticator: BiometricAuthenticator,
        securityRiskDetector: SecurityRiskDetector = SecurityRiskDetector()
    ) {
        self.configuration = configuration
        self.capabilityDetector = capabilityDetector
        self.authenticator = authenticator
        self.securityRiskDetector = securityRiskDetector
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
    
    /// Performs biometric authentication with optional security checks.
    /// - Parameters:
    ///   - reason: Message shown to user in the authentication prompt
    ///   - securityPolicy: Override security policy for this call (default: nil = use configuration)
    ///   - completion: Called on main thread with authentication result
    public func authenticate(
        reason: String = "Authenticate to continue",
        securityPolicy: SecurityPolicy? = nil,
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        // Work on serial queue to keep internal state usage consistent
        queue.async { [configuration, capabilityDetector, authenticator, securityRiskDetector] in
            // Determine which policy to use (override or configured)
            let policyToUse = securityPolicy ?? configuration.securityPolicy
            
            // Perform security checks if policy is set
            if let policy = policyToUse, !policy.blockedRisks.isEmpty {
                let riskResult = securityRiskDetector.assessAllRisks()
                
                // Check if any detected risk is blocked by the policy
                let blockedDetectedRisks = riskResult.detectedRisks.intersection(policy.blockedRisks)
                if !blockedDetectedRisks.isEmpty {
                    let blockedResult = SecurityRiskResult(detectedRisks: blockedDetectedRisks)
                    DispatchQueue.main.async {
                        completion(.failure(.securityRiskDetected(blockedResult)))
                    }
                    return
                }
            }
            
            // Check biometric availability
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

