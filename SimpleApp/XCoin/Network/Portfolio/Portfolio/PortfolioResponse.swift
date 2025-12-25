//
//  PortfolioResponse.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation

// MARK: - PortfolioResponse
struct PortfolioResponse: Codable {
    let portfolioList: [PortfolioCoin]?
}

// MARK: - PortfolioList
struct PortfolioCoin: Codable {
    let longName, shortName: String?
    let currentPrice, changeRatio: Double?
    let currency: String?
    let amount: Double?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case longName, shortName, currentPrice, changeRatio, currency, amount
        case imageURL = "imageUrl"
    }
}
