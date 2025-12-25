//
//  SecuritySettingsPresenter.swift
//  CoinX
//

import Foundation

class SecuritySettingsPresenter: SecuritySettings.Presenter {
    
    weak var view: SecuritySettings.View?
    var interactor: SecuritySettings.Interactor!
    var router: SecuritySettings.Router!
    
    func notifyViewLoaded() {
        interactor.loadSettings()
    }
    
    func didLoadSettings(_ settings: SecuritySettingsState) {
        view?.updateSettings(settings)
    }
    
    func toggleBiometric(_ enabled: Bool) {
        interactor.updateBiometricEnabled(enabled)
    }
    
    func toggleBlockOnJailbreak(_ enabled: Bool) {
        interactor.updateBlockOnJailbreak(enabled)
    }
    
    func toggleBlockOnSimulator(_ enabled: Bool) {
        interactor.updateBlockOnSimulator(enabled)
    }
    
    func toggleBlockOnHooking(_ enabled: Bool) {
        interactor.updateBlockOnHooking(enabled)
    }
    
    func toggleBlockOnDebugger(_ enabled: Bool) {
        interactor.updateBlockOnDebugger(enabled)
    }
}

