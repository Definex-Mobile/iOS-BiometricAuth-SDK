//
//  PortfolioPresenter.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import Foundation

class PortfolioPresenter: Portfolio.Presenter {
    
    weak var view: Portfolio.View?
    var interactor: Portfolio.Interactor!
    var router: Portfolio.Router!
    
    func notifyViewLoaded() {
        view?.showLoading()
        interactor.fetchCoins()
    }
    
    func didFetchCoins() {
        view?.hideLoading()
        
        var items: [Portfolio.ListItem] = [
            .portfolio,
            .emptyRow(16.0),
            .depositWithdraw,
            .emptyRow(32.0),
            .title(text: "Trending Coins"),
            .emptyRow(1)
        ]
        
        if !interactor.coins.isEmpty {
            items.append(contentsOf: interactor.coins.map{ .coin(makeRowItem($0)) })
        }
        
        view?.updateTableView(with: items)
    }
    
    private func didCoinPressed(_ coin: Portfolio.ListRowItem) {
        // TODO:
    }
}

private extension PortfolioPresenter {
    
    func makeRowItem(_ coin: PortfolioCoin) -> Portfolio.ListRowItem {
        return Portfolio.ListRowItem.init(
            longName: coin.longName ?? "",
            shortName: coin.shortName ?? "",
            imageUrl: coin.imageURL ?? "",
            value: String(coin.currentPrice ?? 0),
            changePercentage: String(coin.changeRatio ?? 0),
            isChangePositive: (coin.changeRatio ?? 0) > 0,
            onItemClicked: didCoinPressed(_:)
        )
    }
    
}
