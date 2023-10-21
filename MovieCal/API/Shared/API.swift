//
//  API.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

protocol API {
    var baseURL: URL { get }
    static var defaultParameters: [String: String] { get }
    
    var path: String { get }
    var parameters: [String: String] { get }
}

extension API {
    private var allParameters: [String: String] {
        Self.defaultParameters.merging(parameters, uniquingKeysWith: { a, b in b })
    }
    var url: URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = baseURL.path + path // the `URLComponents` is dropping the baseURL path
        components.queryItems = allParameters.map {
            .init(name: $0.key, value: $0.value)
        }
        return components.url!
    }
    var request: URLRequest {
        let request = URLRequest(url: url)
        return request
    }
}

extension API {
    @discardableResult
    func retrieve<T: Decodable>(_ type: T.Type, completion: @escaping  BlockIn<Result<T, APIError>>) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(.failure(.general))
                return
            } else if let data = data {
                do {
                    let value = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(value))
                } catch {
                    print(error)
                    print(data.string ?? "COULDN'T DECODE STRING FROM DATA")
                    completion(.failure(.general))
                }
            } else {
                // Got no data or error
                completion(.failure(.general))
            }
        }
        
        task.resume()
        
        return task
    }
}
