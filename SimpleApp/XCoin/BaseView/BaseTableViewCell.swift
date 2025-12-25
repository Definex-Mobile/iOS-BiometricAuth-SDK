//
//  BaseTableViewCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
}
