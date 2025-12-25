//
//  XButton.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 15.09.2023.
//

import UIKit

class XButton: UIButton {
    
    enum StatusShape: Int {
        case minimal
        case filled
        case bordered
    }
    
    var shape: StatusShape = .minimal
    
    @IBInspectable var shapeAdapter:Int {
        get {
            return self.shape.rawValue
        }
        set(shapeIndex) {
            self.shape = StatusShape(rawValue: shapeIndex) ?? .minimal
            prepareDesign()
        }
    }
    
    @IBInspectable var textColor: UIColor {
        get {
            return self.titleColor(for: .normal) ?? .black
        }
        set(color) {
            setTitleColor(color, for: .normal)
        }
    }
    
    @IBInspectable var buttonText: String? {
        get {
            return self.titleLabel?.text
        }
        set(text) {
            setTitle(text, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepareDesign()
    }
    
    func prepareDesign() {
        switch shape {
        case .minimal:
            titleLabel?.font = theme.lightItalic12
            backgroundColor = .white
            layer.cornerRadius = 4
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: 88),
                self.heightAnchor.constraint(equalToConstant: 30)
            ])
        case .filled:
            titleLabel?.font = theme.medium14
            backgroundColor = UIColor.init(named: "Primary")
            layer.cornerRadius = 4
            NSLayoutConstraint.deactivate(self.constraints)
            NSLayoutConstraint.activate([
                self.heightAnchor.constraint(equalToConstant: 48)
            ])
        case .bordered:
            titleLabel?.font = theme.medium14
            backgroundColor = .white
            layer.cornerRadius = 4
            layer.borderWidth = 1
            layer.borderColor = UIColor.init(named: "Primary")!.cgColor
            NSLayoutConstraint.deactivate(self.constraints)
            NSLayoutConstraint.activate([
                self.heightAnchor.constraint(equalToConstant: 48)
            ])
        }
    }
}
