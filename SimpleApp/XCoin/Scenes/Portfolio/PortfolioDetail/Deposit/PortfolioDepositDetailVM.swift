//
//  PortfolioDepositDetailVM.swift
//  XCoin
//
//  Created by Serkan Kara on 23.10.2024.
//

import Foundation

final class PortfolioDepositDetailVM {
    
    deinit {
        print("deInit PortfolioDepositDetailVM")
    }
    
    var bindItems: (([TrendingCoin])->())?
    
    let items = [TrendingCoin(longName: "", shortName: "", currentPrice: 0, changeRatio: 0, currency: "", imageURL: "")]

    func getItems() {
        bindItems?(items)
    }
}
