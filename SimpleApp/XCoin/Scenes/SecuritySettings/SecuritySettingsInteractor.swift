//
//  SecuritySettingsInteractor.swift
//  CoinX
//

import Foundation

class SecuritySettingsInteractor: SecuritySettings.Interactor {
    
    weak var presenter: SecuritySettings.Presenter?
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let biometricEnabled = "biometric_enabled"
        static let blockOnJailbreak = "security_block_jailbreak"
        static let blockOnSimulator = "security_block_simulator"
        static let blockOnHooking = "security_block_hooking"
        static let blockOnDebugger = "security_block_debugger"
    }
    
    func loadSettings() {
        let state = SecuritySettingsState(
            isBiometricEnabled: defaults.object(forKey: Keys.biometricEnabled) as? Bool ?? true,
            blockOnJailbreak: defaults.object(forKey: Keys.blockOnJailbreak) as? Bool ?? true,
            blockOnSimulator: defaults.object(forKey: Keys.blockOnSimulator) as? Bool ?? true,
            blockOnHooking: defaults.object(forKey: Keys.blockOnHooking) as? Bool ?? true,
            blockOnDebugger: defaults.object(forKey: Keys.blockOnDebugger) as? Bool ?? false
        )
        presenter?.didLoadSettings(state)
    }
    
    func updateBiometricEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.biometricEnabled)
        loadSettings()
    }
    
    func updateBlockOnJailbreak(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.blockOnJailbreak)
        loadSettings()
    }
    
    func updateBlockOnSimulator(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.blockOnSimulator)
        loadSettings()
    }
    
    func updateBlockOnHooking(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.blockOnHooking)
        loadSettings()
    }
    
    func updateBlockOnDebugger(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.blockOnDebugger)
        loadSettings()
    }
}

