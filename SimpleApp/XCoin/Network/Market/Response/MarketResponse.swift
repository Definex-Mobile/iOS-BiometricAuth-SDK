//
//  MarketResponse.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import Foundation

struct MarketResponse: Codable {
    let marketList: [Market]?
}

struct Market: Codable {
    let longName, shortName: String?
    let currentPrice, changeRatio: Double?
    let currency: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case longName, shortName, currentPrice, changeRatio, currency
        case imageURL = "imageUrl"
    }
}
