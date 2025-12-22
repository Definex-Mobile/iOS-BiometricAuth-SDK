import Foundation
import LocalAuthentication
@testable import DefXBiometric

/// Mock implementation of LAContextProtocol for unit testing.
@available(iOS 11.0, macOS 10.13.2, *)
final class MockLAContext: LAContextProtocol {
    
    // MARK: - Configurable Properties
    
    /// Controls the return value of canEvaluatePolicy
    var canEvaluateResult: Bool = true
    
    /// Controls the error returned by canEvaluatePolicy (via NSErrorPointer)
    var canEvaluateError: NSError?
    
    /// Controls the biometry type returned by the context
    var biometryTypeToReturn: LABiometryType = .faceID
    
    /// Controls the result of evaluatePolicy (success flag and optional error)
    var evaluatePolicyResult: (success: Bool, error: Error?) = (true, nil)
    
    /// If true, the reply closure will be called twice (to test completion-once protection)
    var shouldCallReplyTwice: Bool = false
    
    /// If true, reply will be called on a background thread (to test main thread enforcement)
    var shouldReplyOnBackgroundThread: Bool = false
    
    /// Custom title for the fallback button
    var localizedFallbackTitle: String?
    
    // MARK: - Call Tracking
    
    /// Number of times canEvaluatePolicy was called
    private(set) var canEvaluatePolicyCallCount: Int = 0
    
    /// Number of times evaluatePolicy was called
    private(set) var evaluatePolicyCallCount: Int = 0
    
    /// Last policy passed to canEvaluatePolicy
    private(set) var lastCanEvaluatePolicy: LAPolicy?
    
    /// Last policy passed to evaluatePolicy
    private(set) var lastEvaluatePolicy: LAPolicy?
    
    /// Last reason passed to evaluatePolicy
    private(set) var lastEvaluateReason: String?
    
    // MARK: - LAContextProtocol Implementation
    
    var biometryType: LABiometryType {
        return biometryTypeToReturn
    }
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyCallCount += 1
        lastCanEvaluatePolicy = policy
        
        if let errorToReturn = canEvaluateError {
            error?.pointee = errorToReturn
        }
        
        return canEvaluateResult
    }
    
    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String,
        reply: @escaping @Sendable (Bool, Error?) -> Void
    ) {
        evaluatePolicyCallCount += 1
        lastEvaluatePolicy = policy
        lastEvaluateReason = localizedReason
        
        let result = evaluatePolicyResult
        
        let executeReply = {
            reply(result.success, result.error)
            
            // If configured, call reply a second time (to test completion-once protection)
            if self.shouldCallReplyTwice {
                reply(result.success, result.error)
            }
        }
        
        if shouldReplyOnBackgroundThread {
            // Call on background thread to test main thread enforcement
            DispatchQueue.global(qos: .userInitiated).async {
                executeReply()
            }
        } else {
            // Call asynchronously (simulating LAContext behavior)
            DispatchQueue.main.async {
                executeReply()
            }
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all call counters and tracked values
    func reset() {
        canEvaluatePolicyCallCount = 0
        evaluatePolicyCallCount = 0
        lastCanEvaluatePolicy = nil
        lastEvaluatePolicy = nil
        lastEvaluateReason = nil
        localizedFallbackTitle = nil
    }
}
