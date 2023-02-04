//
//  RequestError.swift
//  EasyNetwork
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

public enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
    
    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        case .invalidURL:
            return "Invalid URL"
        case .noResponse:
            return "No response"
        case . unexpectedStatusCode:
            return "Unexpected status code"
        case .unknown:
            return "Unknown error"
        }
    }
}
