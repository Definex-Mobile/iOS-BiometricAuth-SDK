//
//  RepositoriesNetworkşng.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import Foundation
import Alamofire

enum MarketsNetworking {
    case getAllMarkets
    case getFavoriteMarkets
    case getGainers
    case getLosers
    case getStatus
}

extension MarketsNetworking: TargetType {
    
    var baseURL: String {
        switch self {
        default:
            return "https://xcoin-70afa.web.app/api/market/"
        }
    }
    
    var path: String {
        switch self {
        case .getAllMarkets:
            return "ALL/marketList.json"
        case .getFavoriteMarkets:
            return "FAVORITES/marketList.ison"
        case .getGainers:
            return "GAINERS/marketList.json"
        case .getLosers:
            return "LOSERS/marketList.ison"
        case .getStatus:
            return "status.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllMarkets:
            return .get
        case .getFavoriteMarkets:
            return .get
        case .getGainers:
            return .get
        case .getLosers:
            return .get
        case .getStatus:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAllMarkets:
            return .requestPlain
        case .getFavoriteMarkets:
            return .requestPlain
        case .getGainers:
            return .requestPlain
        case .getLosers:
            return .requestPlain
        case .getStatus:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return [:]
        }
    }
}
