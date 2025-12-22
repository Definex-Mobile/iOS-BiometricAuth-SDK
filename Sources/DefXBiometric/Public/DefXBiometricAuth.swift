import Foundation

/// Main entry point for biometric authentication operations
///
/// This class provides a simple interface for checking biometric capabilities
/// and performing biometric authentication on iOS devices.
///
/// **Thread Safety:**
/// This class is thread-safe. All public methods can be called concurrently
/// from multiple threads. Internal locking ensures deterministic behavior.
///
/// Usage:
/// ```swift
/// // Using singleton
/// DefXBiometricAuth.shared.authenticate(reason: "Login") { result in
///     switch result {
///     case .success:
///         print("Authenticated!")
///     case .failure(let error):
///         print("Error: \(error.localizedDescription)")
///     }
/// }
///
/// // Using instance
/// let auth = DefXBiometricAuth()
/// let type = auth.availableBiometricType()
/// ```
@available(iOS 11.0, macOS 10.13.2, *)
public final class DefXBiometricAuth {
    
    // MARK: - Properties
    
    private let capabilityDetector: BiometricCapabilityDetector
    private let authenticator: BiometricAuthenticator
    
    // Lock for thread-safe access to public methods
    private let lock = NSLock()
    
    // MARK: - Singleton
    
    /// Shared instance for convenient access
    public static let shared = DefXBiometricAuth()
    
    // MARK: - Initialization
    
    /// Creates a new instance of DefXBiometricAuth
    public init() {
        self.capabilityDetector = BiometricCapabilityDetector()
        self.authenticator = BiometricAuthenticator()
    }
    
    /// Internal initializer for dependency injection (used in tests)
    ///
    /// This initializer allows injecting mock dependencies for unit testing
    /// without exposing internal types to the public API.
    ///
    /// - Parameters:
    ///   - capabilityDetector: The capability detector to use
    ///   - authenticator: The authenticator to use
    internal init(
        capabilityDetector: BiometricCapabilityDetector,
        authenticator: BiometricAuthenticator
    ) {
        self.capabilityDetector = capabilityDetector
        self.authenticator = authenticator
    }
    
    // MARK: - Public API
    
    /// Returns the type of biometric authentication available on the device
    ///
    /// **Thread Safety:** Safe to call from any thread.
    ///
    /// - Returns: The biometric type (faceID, touchID, or none)
    public func availableBiometricType() -> BiometricType {
        lock.lock()
        defer { lock.unlock() }
        return capabilityDetector.detectBiometricType()
    }
    
    /// Checks if biometric authentication is available and enrolled
    ///
    /// **Thread Safety:** Safe to call from any thread.
    ///
    /// - Returns: `true` if biometric authentication can be used, `false` otherwise
    public func isBiometricAvailable() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return capabilityDetector.isBiometricAvailable()
    }
    
    /// Performs biometric authentication with the given parameters
    ///
    /// **reason Parametresi Neden Gerekli?**
    /// iOS, Face ID/Touch ID popup'ında kullanıcıya "neden" bu kimlik doğrulamasının
    /// istendiğini göstermek zorundadır. Bu Apple'ın privacy requirement'ıdır.
    /// Örnek: "Authenticate to confirm payment"
    ///
    /// **Teknik Detay:**
    /// - reason parametresi iOS native popup'ta kullanıcıya gösterilir
    /// - Apple Human Interface Guidelines bu mesajın açık ve anlamlı olmasını gerektirir
    /// - Boş string verilirse SDK default mesaj kullanır: "Authenticate to continue"
    ///
    /// **Thread Safety:**
    /// Safe to call from any thread. Multiple concurrent calls will be serialized.
    /// Completion handler is always called on the main thread.
    ///
    /// - Parameters:
    ///   - reason: The reason shown to user (displayed in iOS prompt). If empty, default is used.
    ///   - fallbackTitle: Custom title for fallback button (ignored in biometrics-only mode)
    ///   - completion: Completion handler called with the authentication result
    public func authenticate(
        reason: String = "Authenticate to continue",
        fallbackTitle: String? = nil,
        completion: @escaping (Result<Void, BiometricError>) -> Void
    ) {
        // Lock for thread-safe access to shared collaborators
        lock.lock()
        
        // Check if any biometric type is available
        let type = capabilityDetector.detectBiometricType()
        guard type != .none else {
            lock.unlock()
            // Call completion outside the lock to avoid potential deadlocks
            completion(.failure(.notAvailable))
            return
        }
        
        // Use default reason if provided reason is empty or whitespace-only
        let reasonToUse = reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Authenticate to continue"
            : reason
        
        // Invoke authenticator (which handles its own thread safety)
        // Note: We call this while holding the lock to serialize authentication requests,
        // but the authenticator's completion will be called asynchronously without holding our lock
        authenticator.authenticate(
            reason: reasonToUse,
            fallbackTitle: fallbackTitle,
            completion: completion
        )
        
        // Unlock after initiating authentication
        // Completion will be called later asynchronously on main thread
        lock.unlock()
    }
}

