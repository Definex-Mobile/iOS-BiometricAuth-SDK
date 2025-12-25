//
//  PortfolioHelper.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

extension Portfolio {
    
    static func createModule() -> UIViewController {
        // Create layers
        let view = PortfolioViewController()
        let interactor = PortfolioInteractor()
        let presenter = PortfolioPresenter()
        let router = PortfolioRouter()
        
        // Connect layers
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.interactor = interactor
        presenter.view = view
        presenter.router = router
        router.presentingVC = view
        
        return view
    }
}


