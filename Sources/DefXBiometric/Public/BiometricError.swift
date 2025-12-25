import Foundation

/// Errors that can occur during biometric authentication.
public enum BiometricError: Error, Equatable {
    /// Biometric authentication is not available on this device
    case notAvailable
    
    /// No biometric data is enrolled on this device
    case notEnrolled
    
    /// Biometric authentication is locked due to too many failed attempts
    case lockout
    
    /// User cancelled the authentication
    case cancelled
    
    /// User chose to use the fallback method
    case fallback
    
    /// Biometric authentication failed (wrong face/fingerprint)
    case authenticationFailed
    
    /// Security risk detected, authentication blocked
    case securityRiskDetected(SecurityRiskResult)
    
    /// A system error occurred
    case systemError(String)
    
    /// An unknown error occurred
    case unknown
}

// MARK: - Error Identifiers
extension BiometricError {
    /// Returns a stable string identifier for the error type.
    public var identifier: String {
        switch self {
        case .notAvailable: return "biometric_error_not_available"
        case .notEnrolled: return "biometric_error_not_enrolled"
        case .lockout: return "biometric_error_lockout"
        case .cancelled: return "biometric_error_cancelled"
        case .fallback: return "biometric_error_fallback"
        case .authenticationFailed: return "biometric_error_authentication_failed"
        case .securityRiskDetected: return "biometric_error_security_risk"
        case .systemError: return "biometric_error_system"
        case .unknown: return "biometric_error_unknown"
        }
    }
}

