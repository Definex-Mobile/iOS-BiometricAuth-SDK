//
//  SecuritySettingsContract.swift
//  CoinX
//

import Foundation

protocol SecuritySettingsViewProtocol: BaseView {
    var presenter: SecuritySettings.Presenter! { get set }
    
    func updateSettings(_ settings: SecuritySettingsState)
}

protocol SecuritySettingsInteractorProtocol: AnyObject {
    var presenter: SecuritySettings.Presenter? { get set }
    
    func loadSettings()
    func updateBiometricEnabled(_ enabled: Bool)
    func updateBlockOnJailbreak(_ enabled: Bool)
    func updateBlockOnSimulator(_ enabled: Bool)
    func updateBlockOnHooking(_ enabled: Bool)
    func updateBlockOnDebugger(_ enabled: Bool)
}

protocol SecuritySettingsPresenterProtocol: BasePresenter {
    var view: SecuritySettings.View? { get set }
    var interactor: SecuritySettings.Interactor! { get set }
    var router: SecuritySettings.Router! { get set }
    
    func didLoadSettings(_ settings: SecuritySettingsState)
    func toggleBiometric(_ enabled: Bool)
    func toggleBlockOnJailbreak(_ enabled: Bool)
    func toggleBlockOnSimulator(_ enabled: Bool)
    func toggleBlockOnHooking(_ enabled: Bool)
    func toggleBlockOnDebugger(_ enabled: Bool)
}

protocol SecuritySettingsRouterProtocol: BaseRouter {
    var presenter: SecuritySettings.Presenter? { get set }
}

struct SecuritySettings {
    typealias View = SecuritySettingsViewProtocol
    typealias Interactor = SecuritySettingsInteractorProtocol
    typealias Presenter = SecuritySettingsPresenterProtocol
    typealias Router = SecuritySettingsRouterProtocol
}

struct SecuritySettingsState {
    var isBiometricEnabled: Bool
    var blockOnJailbreak: Bool
    var blockOnSimulator: Bool
    var blockOnHooking: Bool
    var blockOnDebugger: Bool
}

extension SecuritySettings.Presenter {
    var _view: BaseView? { view }
}

