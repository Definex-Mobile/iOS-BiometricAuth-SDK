//
//  Cell+Extension.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 19.09.2023.
//

import UIKit

// MARK: - Reuse Identifiable
protocol ReuseIdentifiable {
    static func reuseIdentifier() -> String
}

extension ReuseIdentifiable {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

// MARK: - UITableViewCell & UICollectionViewCell
extension UITableViewCell: ReuseIdentifiable {}
extension UICollectionViewCell: ReuseIdentifiable {}
