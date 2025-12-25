import Foundation

/// Configuration for DefXBiometric SDK.
public struct DefXBiometricConfiguration: Equatable {
    /// Security policy to apply during authentication.
    /// If nil, no security checks are performed (default behavior).
    public let securityPolicy: SecurityPolicy?
    
    /// Creates a configuration
    /// - Parameter securityPolicy: Optional security policy (default: nil = disabled)
    public init(securityPolicy: SecurityPolicy? = nil) {
        self.securityPolicy = securityPolicy
    }
    
    /// Default configuration with no security checks
    public static let `default` = DefXBiometricConfiguration(
        securityPolicy: nil
    )
    
    /// Configuration with strict security checks
    public static let secure = DefXBiometricConfiguration(
        securityPolicy: .strict
    )
}

