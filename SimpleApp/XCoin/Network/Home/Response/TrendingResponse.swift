//
//  TrendingResponse.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import Foundation

// MARK: - TrendingResponse
struct TrendingResponse: Codable {
    let trendingList: [TrendingCoin]?
}

// MARK: - TrendingList
struct TrendingCoin: Codable {
    let longName, shortName: String?
    let currentPrice, changeRatio: Double?
    let currency: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case longName, shortName, currentPrice, changeRatio, currency
        case imageURL = "imageUrl"
    }
}
