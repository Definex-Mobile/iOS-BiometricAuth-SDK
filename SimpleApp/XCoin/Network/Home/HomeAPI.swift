//
//  PortfolioAPI.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation
import Alamofire

protocol HomeAPIProtocol {
    func fetchList(completionHandler: @escaping (Result<TrendingResponse, NSError>) -> Void)
}


class HomeAPI: BaseAPI<HomeNetworking>, HomeAPIProtocol {
    
    func fetchList(completionHandler: @escaping (Result<TrendingResponse, NSError>) -> Void) {
        fetchData(target: .getList, responseClass: TrendingResponse.self, completionHandler: completionHandler)
    }
}


