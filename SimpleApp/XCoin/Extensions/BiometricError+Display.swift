//
//  BiometricError+Display.swift
//  CoinX
//

import Foundation
import DefXBiometric

extension BiometricError {
    
    var displayTitle: String {
        switch self {
        case .notAvailable:
            return "Biometric Not Available"
        case .notEnrolled:
            return "Biometric Not Enrolled"
        case .lockout:
            return "Biometric Locked"
        case .cancelled:
            return "Authentication Cancelled"
        case .fallback:
            return "Fallback Selected"
        case .authenticationFailed:
            return "Authentication Failed"
        case .systemError:
            return "System Error"
        case .unknown:
            return "Unknown Error"
        case .securityRiskDetected:
            return "Security Risk Detected"
        }
    }
    
    var displayMessage: String {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device."
        case .notEnrolled:
            return "No biometric data is enrolled. Please set up Face ID or Touch ID in Settings."
        case .lockout:
            return "Biometric authentication is locked due to too many failed attempts."
        case .cancelled:
            return "You cancelled the authentication."
        case .fallback:
            return "You chose to use the fallback method."
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .systemError(let message):
            return "A system error occurred: \(message)"
        case .unknown:
            return "An unknown error occurred."
        case .securityRiskDetected(let result):
            if result.detectedRisks.isEmpty {
                return "Security risk detected."
            }
            
            let riskNames = result.detectedRisks.map { risk -> String in
                switch risk {
                case .jailbreak: return "Jailbreak"
                case .simulator: return "Simulator"
                case .debugger: return "Debugger"
                case .hooking: return "Hooking"
                }
            }.sorted().joined(separator: ", ")
            
            return "Security risks detected: \(riskNames)"
        }
    }
}

