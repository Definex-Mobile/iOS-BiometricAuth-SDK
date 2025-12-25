//
//  TargetType.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import Foundation
import Alamofire

enum HTTPMethods: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
}

enum Task {
    
    case requestPlain
    
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
}

protocol TargetType {
    
    var baseURL: String {get}
    
    var path: String {get}
    
    var method: HTTPMethod {get}
    
    var task: Task {get}
    
    var headers: [String: String]? {get}
}
