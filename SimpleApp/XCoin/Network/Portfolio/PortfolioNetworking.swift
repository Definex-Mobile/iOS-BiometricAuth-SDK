//
//  PortfolioNetworking.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation
import Alamofire

enum PortfolioNetworking {
    case getList
}

extension PortfolioNetworking: TargetType {
    
    var baseURL: String {
        switch self {
        default:
            return "https://xcoin-70afa.web.app/api/portfolio"
        }
    }
    
    var path: String {
        switch self {
        case .getList:
            return "/portfolioList.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getList:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return [:]
        }
    }
}

