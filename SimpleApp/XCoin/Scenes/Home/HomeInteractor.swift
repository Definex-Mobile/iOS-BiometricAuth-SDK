//
//  HomeInteractor.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation

class HomeInteractor: Home.Interactor {
    
    private var repository = HomeAPI()
    
    var presenter: Home.Presenter?
    
    var markets: [TrendingCoin] = []
    
    func fetchMarkets() {
        repository.fetchList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                self.markets = res.trendingList ?? []
                self.presenter?.didFetchMarkets()
            case .failure(let error):
                self.presenter?.didReceiveError(error)
            }
        }
    }
}
