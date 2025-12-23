import Foundation
import LocalAuthentication

/// Protocol abstraction for LAContext to enable testing.
@available(iOS 11.0, macOS 10.13.2, *)
internal protocol LAContextProtocol {
    /// Evaluates the specified policy
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    
    /// Returns the biometry type available on the device
    var biometryType: LABiometryType { get }
    
    /// Evaluates the policy asynchronously
    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String,
        reply: @escaping @Sendable (Bool, Error?) -> Void
    )
}

// MARK: - LAContext Conformance
@available(iOS 11.0, macOS 10.13.2, *)
extension LAContext: LAContextProtocol {}

