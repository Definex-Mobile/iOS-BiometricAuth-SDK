import Foundation
import LocalAuthentication

/// Detects the biometric capabilities of the device
///
/// This class is responsible for determining what type of biometric authentication
/// is available on the current device (Face ID, Touch ID, or none).
///
/// **Thread Safety:**
/// This class is thread-safe. Each method call creates a fresh LAContext instance
/// via the contextFactory, preventing concurrent access issues with shared state.
@available(iOS 11.0, macOS 10.13.2, *)
internal final class BiometricCapabilityDetector {
    
    // MARK: - Properties
    
    // Context factory creates fresh LAContext for each call (thread-safe)
    private let contextFactory: () -> LAContextProtocol
    
    // MARK: - Initialization
    
    init(contextFactory: @escaping () -> LAContextProtocol = { LAContext() }) {
        self.contextFactory = contextFactory
    }
    
    // MARK: - Internal Methods
    
    /// Detects the available biometric type on the device
    ///
    /// **Thread Safety:** Safe to call from any thread. Creates fresh LAContext internally.
    ///
    /// - Returns: The type of biometric authentication available
    func detectBiometricType() -> BiometricType {
        // Create fresh context for this call (thread-safe)
        let context = contextFactory()
        var error: NSError?
        
        // Check if device can evaluate biometric policy
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // If cannot evaluate, return none
            return .none
        }
        
        // Map LABiometryType to BiometricType
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            // Optic ID (Vision Pro) - treat as faceID for compatibility
            return .faceID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    /// Checks if biometric authentication is available and enrolled
    ///
    /// **Thread Safety:** Safe to call from any thread. Creates fresh LAContext internally.
    ///
    /// - Returns: `true` if biometrics can be used, `false` otherwise
    func isBiometricAvailable() -> Bool {
        // Create fresh context for this call (thread-safe)
        let context = contextFactory()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

