import Foundation
import LocalAuthentication

/// Detects the biometric capabilities of the device (Face ID, Touch ID, or none).
@available(iOS 11.0, macOS 10.13.2, *)
internal final class BiometricCapabilityDetector {
    
    // MARK: - Properties
    
    private let contextFactory: () -> LAContextProtocol
    
    // MARK: - Initialization
    
    init(contextFactory: @escaping () -> LAContextProtocol = { LAContext() }) {
        self.contextFactory = contextFactory
    }
    
    // MARK: - Internal Methods
    
    /// Detects the available biometric type on the device.
    /// - Returns: The type of biometric authentication available
    func detectBiometricType() -> BiometricType {
        let context = contextFactory()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .faceID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    /// Checks if biometric authentication is available and enrolled.
    /// - Returns: `true` if biometrics can be used, `false` otherwise
    func isBiometricAvailable() -> Bool {
        let context = contextFactory()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

