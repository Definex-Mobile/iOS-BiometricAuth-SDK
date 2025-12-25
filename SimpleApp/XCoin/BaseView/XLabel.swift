//
//  XLabel.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

class XLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepareDesign()
    }
    
    func prepareDesign() { }
}

class XBold20Label: XLabel {
    
    override func prepareDesign() {
        font = theme.bold20
    }
    
}

class XBold28Label: XLabel {
    
    override func prepareDesign() {
        font = theme.bold28
    }
    
}

class XMedium18Label: XLabel {
    
    override func prepareDesign() {
        font = theme.medium18
    }
    
}

class XMedium14Label: XLabel {
    
    override func prepareDesign() {
        font = theme.medium14
    }
}

class XMedium10Label: XLabel {
    
    override func prepareDesign() {
        font = theme.medium10
    }
    
}

class XLightItalic12Label: XLabel {
    
    override func prepareDesign() {
        font = theme.lightItalic12
    }
    
}
