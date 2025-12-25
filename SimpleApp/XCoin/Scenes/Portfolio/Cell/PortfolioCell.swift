//
//  PortfolioCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

class PortfolioCell: BaseTableViewCell {

    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = theme.cornerRadius
    }
}
