//
//  ThemeManager.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

protocol AppTheme {
    var bold20: UIFont { get }
    var bold28: UIFont { get }
    var medium18: UIFont { get }
    var medium14: UIFont { get }
    var medium10: UIFont { get }
    var lightItalic12: UIFont { get }
    var cornerRadius: CGFloat { get }
}

struct MainTheme: AppTheme {
    var bold20: UIFont = UIFont.roboto(weight: .font_bold, with: 20)
    var bold28: UIFont = UIFont.roboto(weight: .font_bold, with: 28)
    var medium18: UIFont = UIFont.roboto(weight: .font_medium, with: 18)
    var medium14: UIFont = UIFont.roboto(weight: .font_medium, with: 14)
    var medium10: UIFont = UIFont.roboto(weight: .font_medium, with: 10)
    var lightItalic12: UIFont = UIFont.roboto(weight: .font_light_italic, with: 12)
    var cornerRadius: CGFloat = 12
}

class ThemeManager {
    
    static let shared = ThemeManager.init(theme: MainTheme())
    
    var theme: AppTheme
    
    private init(theme: AppTheme) {
        self.theme = theme
    }
    
    func setTheme(theme: AppTheme) {
        self.theme = theme
    }
}

let theme = ThemeManager.shared.theme
