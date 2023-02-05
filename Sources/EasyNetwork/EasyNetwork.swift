//
//  EasyNetworkClient.swift
//  EasyNetwork
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

import Foundation
import Combine
 
public protocol EasyNetworkClient: EasyAsyncNetworkClient & EasyCombineNetworkClient {}

public protocol EasyAsyncNetworkClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModelType: T.Type
    ) async -> Result<T, RequestError>
}

public protocol EasyCombineNetworkClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModelType: T.Type
    ) -> AnyPublisher<T, RequestError>
}

//MARK: - Async/await way

public extension EasyNetworkClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModelType: T.Type
    ) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme.rawValue
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        print("request: \(request.description)")
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: body, options: []
            )
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            print("ResponseStatusCode: \(response.statusCode)")
            
            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(
                    responseModelType,
                    from: data
                ) else {
                    return .failure(.decode)
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}

//MARK: - Combine way

public extension EasyNetworkClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModelType: T.Type
    ) -> AnyPublisher<T, RequestError> {
        Deferred {
            Future { promise in
                Task {
                    let result: Result<T, RequestError> = await sendRequest(
                        endpoint: endpoint,
                        responseModelType: responseModelType
                    )
                    switch result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
