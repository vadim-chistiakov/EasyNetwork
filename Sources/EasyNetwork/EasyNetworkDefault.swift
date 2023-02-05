//
//  EasyNetworkDefault.swift
//  
//
//  Created by Vadim Chistiakov on 05.02.2023.
//

import Foundation

final class EasyNetworkDefault: EasyNetworkClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModelType: T.Type
    ) async -> Result<T, RequestError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme.rawValue
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.params
        
        let request = Request(
            urlComponents: urlComponents,
            reqBody: endpoint.body,
            httpMethod: endpoint.method
        )
        
        guard let urlRequest = request.buildURLRequest() else {
            return .failure(.urlMalformed)
        }
        
        print("Url request: \(urlRequest.description)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw RequestError(fromHttpStatusCode: httpResponse.statusCode)
            }
            
            print("ResponseStatusCode: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(
                    responseModelType,
                    from: data
                ) else {
                    return .failure(.decodingError(""))
                }
                return .success(decodedResponse)
            default:
                return .failure(.unknown("Unknown status code"))
            }
        } catch {
            return .failure(handleError(urlRequest, error))
        }
    }
    
    private func handleError(
        _ request: URLRequest,
        _ error: Error
    ) -> RequestError {
        if let error = error as? RequestError {
            return error
        }
        let errorCode = (error as NSError).code
        switch errorCode {
        case NSURLErrorTimedOut:
            return RequestError.timeout
        case NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed:
            return RequestError.noConnection
        case NSURLErrorNetworkConnectionLost:
            return RequestError.lostConnection
        default:
            return RequestError.unknown(error.localizedDescription)
        }
    }
}
