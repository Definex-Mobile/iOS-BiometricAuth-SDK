import XCTest
import LocalAuthentication
@testable import DefXBiometric

/// Unit tests for DefXBiometric SDK.
@available(iOS 11.0, macOS 10.13.2, *)
final class DefXBiometricTests: XCTestCase {
    
    // MARK: - Properties
    
    var mockContext: MockLAContext!
    var authenticator: BiometricAuthenticator!
    var capabilityDetector: BiometricCapabilityDetector!
    var biometricAuth: DefXBiometricAuth!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockContext = MockLAContext()
        
        // Create authenticator with mock context factory
        authenticator = BiometricAuthenticator(contextFactory: { [unowned self] in
            return self.mockContext
        })
        
        // Create capability detector with mock context factory
        capabilityDetector = BiometricCapabilityDetector(contextFactory: { [unowned self] in
            return self.mockContext
        })
        
        // Create DefXBiometricAuth with injected dependencies
        biometricAuth = DefXBiometricAuth(
            capabilityDetector: capabilityDetector,
            authenticator: authenticator
        )
    }
    
    override func tearDown() {
        mockContext = nil
        authenticator = nil
        capabilityDetector = nil
        biometricAuth = nil
        super.tearDown()
    }
    
    // MARK: - A) Capability / Type Detection Tests
    
    func testAvailableBiometricType_ReturnsFaceID_WhenDeviceHasFaceID() {
        // Given: Device with Face ID available
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        
        // When: Checking available biometric type
        let type = biometricAuth.availableBiometricType()
        
        // Then: Should return faceID
        XCTAssertEqual(type, .faceID, "Should return faceID when device has Face ID")
    }
    
    func testAvailableBiometricType_ReturnsTouchID_WhenDeviceHasTouchID() {
        // Given: Device with Touch ID available
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .touchID
        
        // When: Checking available biometric type
        let type = biometricAuth.availableBiometricType()
        
        // Then: Should return touchID
        XCTAssertEqual(type, .touchID, "Should return touchID when device has Touch ID")
    }
    
    func testAvailableBiometricType_ReturnsNone_WhenCannotEvaluatePolicy() {
        // Given: Device cannot evaluate biometric policy
        mockContext.canEvaluateResult = false
        mockContext.biometryTypeToReturn = .faceID // Even if hardware exists
        
        // When: Checking available biometric type
        let type = biometricAuth.availableBiometricType()
        
        // Then: Should return none
        XCTAssertEqual(type, .none, "Should return none when canEvaluatePolicy returns false")
    }
    
    func testAvailableBiometricType_ReturnsNone_WhenBiometryTypeIsNone() {
        // Given: Device has no biometric hardware
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .none
        
        // When: Checking available biometric type
        let type = biometricAuth.availableBiometricType()
        
        // Then: Should return none
        XCTAssertEqual(type, .none, "Should return none when biometryType is .none")
    }
    
    // MARK: - B) Authentication Success Test
    
    func testAuthenticate_ReturnsSuccess_WhenBiometricAuthenticationSucceeds() {
        // Given: Device with Face ID and successful authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test authentication") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return success
        waitForExpectations(timeout: 1.0)
        
        guard case .success = capturedResult else {
            XCTFail("Expected success result, got \(String(describing: capturedResult))")
            return
        }
        
        // Verify evaluatePolicy was called
        XCTAssertEqual(mockContext.evaluatePolicyCallCount, 1, "Should call evaluatePolicy once")
        XCTAssertEqual(mockContext.lastEvaluatePolicy, .deviceOwnerAuthenticationWithBiometrics)
        XCTAssertEqual(mockContext.lastEvaluateReason, "Test authentication")
    }
    
    // MARK: - C) Authentication Failure Mapping Tests
    
    func testAuthenticate_ReturnsBiometryNotAvailable_WhenLAErrorIsBiometryNotAvailable() {
        // Given: Device reports biometry not available
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.biometryNotAvailable.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return notAvailable error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .notAvailable, "Should map LAError.biometryNotAvailable to BiometricError.notAvailable")
    }
    
    func testAuthenticate_ReturnsBiometryNotEnrolled_WhenLAErrorIsBiometryNotEnrolled() {
        // Given: Device has biometry but user hasn't enrolled
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.biometryNotEnrolled.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return notEnrolled error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .notEnrolled, "Should map LAError.biometryNotEnrolled to BiometricError.notEnrolled")
    }
    
    func testAuthenticate_ReturnsBiometryLockout_WhenLAErrorIsBiometryLockout() {
        // Given: Biometry is locked due to too many failed attempts
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.biometryLockout.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return lockout error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .lockout, "Should map LAError.biometryLockout to BiometricError.lockout")
    }
    
    func testAuthenticate_ReturnsCancelled_WhenUserCancels() {
        // Given: User cancels authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.userCancel.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return cancelled error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .cancelled, "Should map LAError.userCancel to BiometricError.cancelled")
    }
    
    func testAuthenticate_ReturnsCancelled_WhenAppCancels() {
        // Given: App cancels authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.appCancel.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return cancelled error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .cancelled, "Should map LAError.appCancel to BiometricError.cancelled")
    }
    
    func testAuthenticate_ReturnsCancelled_WhenSystemCancels() {
        // Given: System cancels authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.systemCancel.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return cancelled error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .cancelled, "Should map LAError.systemCancel to BiometricError.cancelled")
    }
    
    func testAuthenticate_ReturnsAuthenticationFailed_WhenWrongBiometric() {
        // Given: Wrong face/fingerprint provided
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.authenticationFailed.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return authenticationFailed error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .authenticationFailed, "Should map LAError.authenticationFailed to BiometricError.authenticationFailed")
    }
    
    func testAuthenticate_ReturnsFallback_WhenUserChoosesFallback() {
        // Given: User chooses fallback option
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.userFallback.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return fallback error
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .fallback, "Should map LAError.userFallback to BiometricError.fallback")
    }
    
    // MARK: - D) Completion Main Thread Tests
    
    func testAuthenticate_CallsCompletionOnMainThread_OnSuccess() {
        // Given: Successful authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { _ in
            // Then: Completion should be on main thread
            XCTAssertTrue(Thread.isMainThread, "Completion must be called on main thread")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAuthenticate_CallsCompletionOnMainThread_OnFailure() {
        // Given: Failed authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        let error = NSError(domain: LAError.errorDomain, code: LAError.userCancel.rawValue)
        mockContext.evaluatePolicyResult = (success: false, error: error)
        
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { _ in
            // Then: Completion should be on main thread
            XCTAssertTrue(Thread.isMainThread, "Completion must be called on main thread even on failure")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAuthenticate_CallsCompletionOnMainThread_EvenWhenReplyIsOnBackgroundThread() {
        // Given: Mock configured to reply on background thread
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        mockContext.shouldReplyOnBackgroundThread = true
        
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { _ in
            // Then: Completion should still be on main thread
            XCTAssertTrue(Thread.isMainThread, "SDK must ensure completion is on main thread regardless of LAContext reply thread")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) // Longer timeout for thread switching
    }
    
    // MARK: - E) Completion Only Once Tests
    
    func testAuthenticate_CallsCompletionOnlyOnce_EvenIfReplyCalledTwice() {
        // Given: Mock configured to call reply twice
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        mockContext.shouldCallReplyTwice = true
        
        var completionCallCount = 0
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating
        biometricAuth.authenticate(reason: "Test") { _ in
            completionCallCount += 1
            expectation.fulfill()
        }
        
        // Then: Completion should be called exactly once
        waitForExpectations(timeout: 1.0)
        
        // Give extra time to ensure no second call happens
        let waitExpectation = self.expectation(description: "Wait for potential second call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        XCTAssertEqual(completionCallCount, 1, "Completion must be called exactly once, even if LAContext reply is called multiple times")
    }
    
    func testAuthenticate_ThreadSafe_CompletionOnlyOnceWithConcurrentReplyCalls() {
        // Given: Mock configured to call reply from background thread (simulating concurrency)
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        mockContext.shouldReplyOnBackgroundThread = true
        mockContext.shouldCallReplyTwice = true
        
        var completionCallCount = 0
        let completionCountLock = NSLock()
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating with concurrent reply calls
        biometricAuth.authenticate(reason: "Test") { _ in
            completionCountLock.lock()
            completionCallCount += 1
            completionCountLock.unlock()
            expectation.fulfill()
        }
        
        // Then: Even with concurrent reply calls, completion should be called exactly once
        waitForExpectations(timeout: 2.0)
        
        // Wait additional time to ensure no race condition allows second call
        let waitExpectation = self.expectation(description: "Wait for potential race condition")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 1.0)
        
        completionCountLock.lock()
        let finalCount = completionCallCount
        completionCountLock.unlock()
        
        XCTAssertEqual(finalCount, 1, "Thread-safe completion guard must prevent duplicate calls even with concurrent reply invocations")
    }
    
    // MARK: - Additional Integration Tests
    
    func testAuthenticate_ReturnsNotAvailable_WhenBiometricTypeIsNone() {
        // Given: Device with no biometrics
        mockContext.canEvaluateResult = false
        mockContext.biometryTypeToReturn = .none
        
        let expectation = expectation(description: "Authentication completes")
        var capturedResult: Result<Void, BiometricError>?
        
        // When: Attempting to authenticate
        biometricAuth.authenticate(reason: "Test") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then: Should return notAvailable immediately without calling evaluatePolicy
        waitForExpectations(timeout: 1.0)
        
        guard case .failure(let biometricError) = capturedResult else {
            XCTFail("Expected failure result")
            return
        }
        
        XCTAssertEqual(biometricError, .notAvailable, "Should return notAvailable when biometric type is none")
        XCTAssertEqual(mockContext.evaluatePolicyCallCount, 0, "Should not call evaluatePolicy when biometric type is none")
    }
    
    func testIsBiometricAvailable_ReturnsTrue_WhenBiometricsAreAvailable() {
        // Given: Device with biometrics available
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        
        // When: Checking availability
        let isAvailable = biometricAuth.isBiometricAvailable()
        
        // Then: Should return true
        XCTAssertTrue(isAvailable, "Should return true when biometrics are available")
    }
    
    func testIsBiometricAvailable_ReturnsFalse_WhenBiometricsAreNotAvailable() {
        // Given: Device without biometrics
        mockContext.canEvaluateResult = false
        
        // When: Checking availability
        let isAvailable = biometricAuth.isBiometricAvailable()
        
        // Then: Should return false
        XCTAssertFalse(isAvailable, "Should return false when biometrics are not available")
    }
    
    func testSharedInstance_IsAccessible() {
        // Given/When: Accessing shared instance
        let shared = DefXBiometricAuth.shared
        
        // Then: Should not be nil
        XCTAssertNotNil(shared, "Shared instance should be accessible")
    }
    
    func testAuthenticate_UsesDefaultReason_WhenReasonIsEmpty() {
        // Given: Empty reason string
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let expectation = expectation(description: "Authentication completes")
        
        // When: Authenticating with empty reason
        biometricAuth.authenticate(reason: "   ") { _ in
            expectation.fulfill()
        }
        
        // Then: Should use default reason
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockContext.lastEvaluateReason, "Authenticate to continue", "Should use default reason when provided reason is empty or whitespace")
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentCalls_AvailableBiometricType_DoNotCrash() {
        // Given: Device with Face ID
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        
        let iterationCount = 100
        let expectation = expectation(description: "All concurrent calls complete")
        expectation.expectedFulfillmentCount = iterationCount
        
        // When: Calling availableBiometricType concurrently from multiple threads
        DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
            let type = biometricAuth.availableBiometricType()
            
            // Then: Should return consistent result without crashing
            XCTAssertEqual(type, .faceID, "Should consistently return faceID")
            expectation.fulfill()
        }
        
        // Verify all calls completed
        waitForExpectations(timeout: 5.0)
    }
    
    func testConcurrentCalls_IsBiometricAvailable_DoNotCrash() {
        // Given: Device with biometrics available
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        
        let iterationCount = 100
        let expectation = expectation(description: "All concurrent calls complete")
        expectation.expectedFulfillmentCount = iterationCount
        
        // When: Calling isBiometricAvailable concurrently from multiple threads
        DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
            let isAvailable = biometricAuth.isBiometricAvailable()
            
            // Then: Should return consistent result without crashing
            XCTAssertTrue(isAvailable, "Should consistently return true")
            expectation.fulfill()
        }
        
        // Verify all calls completed
        waitForExpectations(timeout: 5.0)
    }
    
    func testConcurrentAuthenticate_CallsCompletionForEachRequest() {
        // Given: Device with Face ID and successful authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let callCount = 5
        let completionLock = NSLock()
        var completionCounter = 0
        
        let expectation = expectation(description: "All authentications complete")
        expectation.expectedFulfillmentCount = callCount
        
        // When: Triggering multiple concurrent authenticate calls
        for i in 0..<callCount {
            DispatchQueue.global(qos: .userInitiated).async {
                self.biometricAuth.authenticate(reason: "Test \(i)") { result in
                    // Then: Each completion should be called exactly once
                    completionLock.lock()
                    completionCounter += 1
                    completionLock.unlock()
                    
                    // Verify success
                    if case .success = result {
                        XCTAssertTrue(true, "Authentication should succeed")
                    } else {
                        XCTFail("Expected success result")
                    }
                    
                    expectation.fulfill()
                }
            }
        }
        
        // Verify all completions called
        waitForExpectations(timeout: 5.0)
        
        completionLock.lock()
        let finalCount = completionCounter
        completionLock.unlock()
        
        XCTAssertEqual(finalCount, callCount, "Each authenticate call should have completion called exactly once")
    }
    
    func testConcurrentAuthenticate_EachCallGetsOwnEvaluatePolicy() {
        // Given: Device with Face ID and successful authentication
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let callCount = 3
        let expectation = expectation(description: "All authentications complete")
        expectation.expectedFulfillmentCount = callCount
        
        // When: Triggering multiple concurrent authenticate calls
        for i in 0..<callCount {
            DispatchQueue.global(qos: .userInitiated).async {
                self.biometricAuth.authenticate(reason: "Concurrent test \(i)") { _ in
                    expectation.fulfill()
                }
            }
        }
        
        // Then: evaluatePolicy should be called for each authenticate request
        waitForExpectations(timeout: 5.0)
        
        // Note: Since authenticate calls are serialized by the lock, and each creates
        // a new context call, we expect evaluatePolicyCallCount to match callCount
        XCTAssertEqual(mockContext.evaluatePolicyCallCount, callCount,
                       "Each concurrent authenticate call should trigger evaluatePolicy")
    }
    
    func testMixedConcurrentCalls_DoNotDeadlock() {
        // Given: Device with Face ID
        mockContext.canEvaluateResult = true
        mockContext.biometryTypeToReturn = .faceID
        mockContext.evaluatePolicyResult = (success: true, error: nil)
        
        let totalOperations = 30
        let expectation = expectation(description: "All operations complete")
        expectation.expectedFulfillmentCount = totalOperations
        
        // When: Mixing different API calls concurrently
        for i in 0..<totalOperations {
            DispatchQueue.global(qos: .userInitiated).async {
                switch i % 3 {
                case 0:
                    // Call availableBiometricType
                    _ = self.biometricAuth.availableBiometricType()
                    expectation.fulfill()
                    
                case 1:
                    // Call isBiometricAvailable
                    _ = self.biometricAuth.isBiometricAvailable()
                    expectation.fulfill()
                    
                case 2:
                    // Call authenticate
                    self.biometricAuth.authenticate(reason: "Mixed test") { _ in
                        expectation.fulfill()
                    }
                    
                default:
                    break
                }
            }
        }
        
        // Then: Should complete without deadlocks or crashes
        waitForExpectations(timeout: 10.0)
        
        // Verify no crashes occurred (test will fail if deadlock or crash happens)
        XCTAssertTrue(true, "All concurrent operations completed successfully")
    }
}

