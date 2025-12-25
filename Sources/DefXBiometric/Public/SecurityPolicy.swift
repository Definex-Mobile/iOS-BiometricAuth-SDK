import Foundation

/// Security policy for biometric authentication.
///
/// Defines which security risks should block authentication.
/// By default, no security checks are performed (opt-in).
public struct SecurityPolicy: Equatable {
    /// Security risks that should block authentication
    public let blockedRisks: Set<SecurityRisk>
    
    /// Creates a custom security policy
    /// - Parameter blockedRisks: Risks that should prevent authentication
    public init(blockedRisks: Set<SecurityRisk>) {
        self.blockedRisks = blockedRisks
    }
    
    /// Strict policy: blocks all security risks
    public static let strict = SecurityPolicy(
        blockedRisks: Set(SecurityRisk.allCases)
    )
    
    /// Permissive policy: only blocks jailbreak and hooking
    public static let permissive = SecurityPolicy(
        blockedRisks: [.jailbreak, .hooking]
    )
    
    /// No checks policy (same as nil, but explicit)
    public static let none = SecurityPolicy(
        blockedRisks: []
    )
}

