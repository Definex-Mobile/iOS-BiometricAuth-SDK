//
//  DepositCell.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

protocol DepositCellDelegate: AnyObject {
    func depositButtonTapped()
    func withdrawButtonTapped()
}

class DepositCell: BaseTableViewCell {

    @IBOutlet private weak var depositButton: XButton!
    @IBOutlet private weak var withdrawButton: XButton!
    
    weak var delegate: DepositCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func setupCell(delegate: DepositCellDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func depositButtonAction(_ sender: Any) {
        delegate?.depositButtonTapped()
    }
    
    @IBAction func withdrawButtonAction(_ sender: Any) {
        delegate?.withdrawButtonTapped()
    }
    
}
