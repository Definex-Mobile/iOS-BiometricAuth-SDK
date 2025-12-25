//
//  PortfolioInteractor.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import Foundation

class PortfolioInteractor: Portfolio.Interactor {
    
    private let repository = PortfolioAPI()
    
    weak var presenter: Portfolio.Presenter?
    
    var coins: [PortfolioCoin] = []
    
    func fetchCoins() {
        repository.fetchList { [weak self] result in
            switch result {
            case .success(let res):
                self?.coins = res.portfolioList ?? []
                self?.presenter?.didFetchCoins()
            case .failure(let error):
                self?.presenter?.didReceiveError(error)
            }
        }
    }
}
