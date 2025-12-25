//
//  PortfolioWithdrawDetailVC.swift
//  XCoin
//
//  Created by Serkan Kara on 23.10.2024.
//

import UIKit

class PortfolioWithdrawDetailVC: UIViewController {
    
    deinit {
        print("deInit PortfolioWithdrawDetailVC")
    }
    
    private var viewModel: PortfolioWithdrawDetailVM!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PortfolioWithdrawDetailVM()
        viewModel.delegate = self
        viewModel.getItems()
    }
}

extension PortfolioWithdrawDetailVC: PortfolioWithdrawDetailVMDelegate {
    func bindItems(items: [TrendingCoin]) {
        print(self)
    }
}
