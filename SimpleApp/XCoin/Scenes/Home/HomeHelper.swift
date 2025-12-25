//
//  HomeHelper.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit

extension Home {
    
    static func createModule() -> UIViewController {
        // Create layers
        let view = HomeViewController()
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        
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

