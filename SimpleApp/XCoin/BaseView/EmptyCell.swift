//
//  EmptyCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit

class EmptyCell: BaseTableViewCell {

    @IBOutlet private weak var emptyViewHeightConstraint: NSLayoutConstraint!
    
    func configure(with height: CGFloat) {
        emptyViewHeightConstraint.constant = height
    }
}
