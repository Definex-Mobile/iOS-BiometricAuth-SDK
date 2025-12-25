//
//  HomeInvestCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import UIKit

class HomeInvestCell: BaseTableViewCell {

    @IBOutlet private weak var investButtonContainerView: XButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
}

private extension HomeInvestCell {
    
    private func setupUI() {
    }
}
