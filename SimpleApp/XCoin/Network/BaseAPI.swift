//
//  BaseAPI.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 11.09.2023.
//

import Foundation
import Alamofire

class BaseAPI<T:TargetType> {
    
    func fetchData<M: Decodable>(target: T, responseClass: M.Type, completionHandler:@escaping (Result<M, NSError>)-> Void) {
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let parameters = buildParams(task: target.task)
        
        AF.request(target.baseURL + target.path, method: method, parameters: parameters.0, encoding: parameters.1, headers: headers).responseData { (response) in
            guard let statusCode = response.response?.statusCode else {
                print("StatusCode not found")
                completionHandler(.failure(NSError()))
                return
            }
            
            if statusCode == 200 || statusCode == 201 {
                guard let jsonResponse = try? response.result.get() else {
                    print("jsonResponse error")
                    completionHandler(.failure(NSError()))
                    return
                }
                guard let responseObj = try? JSONDecoder().decode(M.self, from: jsonResponse) else {
                    print("responseObj error")
                    print("\(responseClass.self)")
                    completionHandler(.failure(NSError()))
                    return
                }
              completionHandler(.success(responseObj))
            } else {
                print("error statusCode is \(statusCode)")
                completionHandler(.failure(NSError()))
                
            }
        }
    }
    
    private func buildParams(task: Task) -> ([String: Any], ParameterEncoding) {
        switch task {
        case .requestPlain:
            return ([:], URLEncoding.default)
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            return (parameters, encoding)
        }
    }
}
