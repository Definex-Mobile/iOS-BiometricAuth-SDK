//
//  PortfolioDepositDetailVC.swift
//  XCoin
//
//  Created by Serkan Kara on 23.10.2024.
//

import UIKit

class PortfolioDepositDetailVC: UIViewController {
    
    deinit {
        print("deInit PortfolioDepositDetailVC")
    }
    
    private var viewModel: PortfolioDepositDetailVM!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PortfolioDepositDetailVM()
        viewModel.bindItems = { [weak self] items in 
            print(self.hashValue)
        }
    }
}
