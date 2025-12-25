//
//  PortfolioAPI.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation
import Alamofire

protocol PortfolioAPIProtocol {
    func fetchList(completionHandler: @escaping (Result<PortfolioResponse, NSError>) -> Void)
}

class PortfolioAPI: BaseAPI<PortfolioNetworking>, PortfolioAPIProtocol {
    
    func fetchList(completionHandler: @escaping (Result<PortfolioResponse, NSError>) -> Void) {
        fetchData(target: .getList, responseClass: PortfolioResponse.self, completionHandler: completionHandler)
    }
}


