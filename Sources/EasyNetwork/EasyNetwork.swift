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
        await EasyNetworkDefault().sendRequest(
            endpoint: endpoint,
            responseModelType: responseModelType
        )
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
