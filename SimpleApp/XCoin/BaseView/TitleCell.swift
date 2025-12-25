//
//  TitleCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit

class TitleCell: BaseTableViewCell {

    @IBOutlet private weak var contentTitleLabel: XBold20Label!
    
    func configure(text: String) {
        contentTitleLabel.text = text
    }
}
