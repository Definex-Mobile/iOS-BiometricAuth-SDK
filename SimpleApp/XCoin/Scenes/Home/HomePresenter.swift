//
//  HomePresenter.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation

class HomePresenter: Home.Presenter {
    
    weak var view: Home.View?
    var interactor: Home.Interactor!
    var router: Home.Router!
    
    func notifyViewLoaded() {
        view?.showLoading()
        interactor.fetchMarkets()
    }
    
    func didFetchMarkets() {
        
        var items: [Home.ListItem] = [
            .invest,
            .emptyRow(8.0),
            .title(text: "Trending Coins"),
            .emptyRow(1)
        ]
        
        if !interactor.markets.isEmpty {
            items.append(contentsOf: interactor.markets.map{ .coin(makeRowItem($0)) })
        }
        
        view?.hideLoading()
        view?.updateTableView(with: items)
    }
    
    private func didCoinPressed(_ item: Home.ListRowItem) {
        // TODO:
    }
}

private extension HomePresenter {
    
    func makeRowItem(_ coin: TrendingCoin) -> Home.ListRowItem {
        return Home.ListRowItem.init(
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
