//
//  PortfolioNetworking.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation
import Alamofire

enum HomeNetworking {
    case getList
}

extension HomeNetworking: TargetType {
    
    var baseURL: String {
        switch self {
        default:
            return "https://xcoin-70afa.web.app/api"
        }
    }
    
    var path: String {
        switch self {
        case .getList:
            return "/trending.json"
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

