import Foundation
import LocalAuthentication

/// Handles biometric authentication operations
///
/// This class wraps LocalAuthentication framework and provides
/// a clean interface for performing biometric authentication.
@available(iOS 11.0, macOS 10.13.2, *)
internal final class BiometricAuthenticator {
    
    // MARK: - Properties
    
    // Context factory to create new contexts for each authentication
    private let contextFactory: () -> LAContextProtocol
    
    // Serial queue for thread-safe access
    private let finishQueue = DispatchQueue(label: "com.definex.defxbiometric.authenticator.finish")

    // MARK: - Initialization
    
    init(contextFactory: @escaping () -> LAContextProtocol = { LAContext() }) {
        self.contextFactory = contextFactory
    }
    
    // MARK: - Internal Methods
    
    /// Performs biometric authentication.
    /// - Parameters:
    ///   - reason: Message shown to user during authentication
    ///   - completion: Called on main thread with result
    func authenticate(
        reason: String,
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        // Create a new context for this authentication
        var context = contextFactory()
        
        // Disable passcode fallback UI by setting empty fallback title
        // Without this, iOS shows "Enter Password" button by default
        context.localizedFallbackTitle = ""
        
        var isFinished = false
        let finish: (Result<Void, BiometricError>) -> Void = { result in
             self.finishQueue.async {
                 guard !isFinished else { return }
                 isFinished = true
                 DispatchQueue.main.async { completion(result) }
             }
         }
        
        // Evaluate biometrics-only policy (no passcode fallback)
        // iOS will handle retry attempts (2-3 tries) within the native prompt
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, error in
            if success {
                finish(.success(()))
            } else {
                finish(.failure(Self.mapError(error)))
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Maps LAError to BiometricError.
    private static func mapError(_ error: Error?) -> BiometricError {
        guard let error = error else { return .unknown }

        let nsError = error as NSError

        guard nsError.domain == LAError.errorDomain else {
            return .systemError(nsError.localizedDescription)
        }

        let laErrorCode = LAError.Code(rawValue: nsError.code)
        
        switch laErrorCode {
        case .userFallback:
            return .fallback
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        case .authenticationFailed:
            return .authenticationFailed
        case .appCancel, .systemCancel, .userCancel:
            return .cancelled
        default:
            return .unknown
        }
    }
}

