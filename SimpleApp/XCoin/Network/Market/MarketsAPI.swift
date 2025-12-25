//
//  Repositories.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import Foundation
import Alamofire

protocol MarketsAPIProtocol {
    func fetchAllMarkets(completionHandler: @escaping (Result<MarketResponse, NSError>) -> Void)
    func fetchMarketStatus(completionHandler: @escaping (Result<MarketStatus, NSError>) -> Void)
}


class MarketsAPI: BaseAPI<MarketsNetworking>, MarketsAPIProtocol {
    
    func fetchAllMarkets(completionHandler: @escaping (Result<MarketResponse, NSError>) -> Void) {
        fetchData(target: .getAllMarkets, responseClass: MarketResponse.self, completionHandler: completionHandler)
    }
    
    func fetchMarketStatus(completionHandler: @escaping (Result<MarketStatus, NSError>) -> Void) {
        fetchData(target: .getStatus, responseClass: MarketStatus.self, completionHandler: completionHandler)
    }
}

