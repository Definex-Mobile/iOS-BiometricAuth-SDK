import Foundation

/// Represents different types of security risks that can be detected.
public enum SecurityRisk: String, CaseIterable {
    /// Device is jailbroken/rooted
    case jailbreak
    
    /// Running on simulator (not a physical device)
    case simulator
    
    /// Debugger is attached to the process
    case debugger
    
    /// Runtime hooking/injection detected (e.g., Frida, Cycript)
    case hooking
}

/// Result of a security risk assessment.
public struct SecurityRiskResult: Equatable {
    /// Detected security risks
    public let detectedRisks: Set<SecurityRisk>
    
    /// Whether any risk was detected
    public var hasRisk: Bool {
        return !detectedRisks.isEmpty
    }
    
    public init(detectedRisks: Set<SecurityRisk>) {
        self.detectedRisks = detectedRisks
    }
}

