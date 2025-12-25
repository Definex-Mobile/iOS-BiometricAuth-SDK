//
//  PortfolioWithdrawDetailVM.swift
//  XCoin
//
//  Created by Serkan Kara on 23.10.2024.
//

import Foundation


protocol PortfolioWithdrawDetailVMDelegate: AnyObject {
    func bindItems(items: [TrendingCoin])
}

final class PortfolioWithdrawDetailVM {
    
    deinit {
        print("deInit PortfolioWithdrawDetailVM")
    }
    
    weak var delegate: PortfolioWithdrawDetailVMDelegate?
    
    let items = [TrendingCoin(longName: "", shortName: "", currentPrice: 0, changeRatio: 0, currency: "", imageURL: "")]
    
    func getItems() {
        delegate?.bindItems(items: items)
    }
}

