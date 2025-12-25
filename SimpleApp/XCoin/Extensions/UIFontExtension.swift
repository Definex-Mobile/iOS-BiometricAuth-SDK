//
//  UIFontExtension.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

public enum Roboto: String {
  case font_bold = "Roboto-Bold"
  case font_italic = "Roboto-Italic"
  case font_light_italic = "Roboto-LightItalic"
  case font_light = "Roboto-Light"
  case font_medium = "Roboto-Medium"
  case font_regular = "Roboto-Regular"
  case font_thin_italic = "Roboto-ThinItalic"
  case font_thin = "Roboto-Thin"
}

extension UIFont {
    
    static func roboto(weight: Roboto, with size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
