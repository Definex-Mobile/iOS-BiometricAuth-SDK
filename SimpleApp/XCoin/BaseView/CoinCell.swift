//
//  CoinCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit
import SDWebImage

class CoinCell: BaseTableViewCell {

    @IBOutlet weak var contanierView: UIView!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinLongnameLabel: XLightItalic12Label!
    @IBOutlet weak var coinShortNameLabel: XLightItalic12Label!
    @IBOutlet weak var coinPriceLabel: XLightItalic12Label!
    @IBOutlet weak var percentageLabel: XMedium10Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        setupUI()
    }
}


private extension CoinCell {
    
    private func setupUI() {
        contanierView.layer.cornerRadius = 8
    }
}
