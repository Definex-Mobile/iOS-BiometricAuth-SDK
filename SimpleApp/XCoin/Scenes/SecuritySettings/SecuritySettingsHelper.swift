//
//  SecuritySettingsHelper.swift
//  CoinX
//

import UIKit

extension SecuritySettings {
    
    static func createModule() -> UIViewController {
        let view = SecuritySettingsViewController()
        let interactor = SecuritySettingsInteractor()
        let presenter = SecuritySettingsPresenter()
        let router = SecuritySettingsRouter()
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.interactor = interactor
        presenter.view = view
        presenter.router = router
        router.presentingVC = view
        
        return view
    }
}

