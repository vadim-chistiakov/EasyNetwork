//
//  RequestError.swift
//  EasyNetwork
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

public enum RequestError: Error, CustomDebugStringConvertible, Equatable {
    /// url not formed for request
    case urlMalformed

    /// decoding response
    case decodingError(String)

    /// http 400
    case badRequest

    /// http 401
    case unauthorized

    /// http 403
    case forbidden

    /// http 404
    case notFound

    /// http 500
    case internalServerError

    /// http 502
    case badGateway

    /// http 503
    case unavailable

    /// request timeout
    case timeout

    /// the network connection was lost
    case lostConnection

    /// internet is not available
    case noConnection
    
    /// Response is empty
    case noResponse

    /// unknown error with message
    case unknown(String)

    init(fromHttpStatusCode code: Int) {
        switch code {
        case 400:
            self = .badRequest
        case 401:
            self = .unauthorized
        case 403:
            self = .forbidden
        case 404:
            self = .notFound
        case 500:
            self = .internalServerError
        case 502:
            self = .badGateway
        case 503:
            self = .unavailable
        default:
            self = .unknown("HTTP code \(code)")
        }
    }

    public var debugDescription: String {
        switch self {
        case .urlMalformed:
            return "Url not formed for request error"
        case .decodingError(let message):
            return "Decoding response error: \(message)"
        case .badRequest:
            return "http 400 error"
        case .unauthorized:
            return "http 401 error"
        case .forbidden:
            return "http 403 error"
        case .notFound:
            return "http 404 error"
        case .internalServerError:
            return "http 500 error"
        case .badGateway:
            return "http 502 error"
        case .unavailable:
            return "http 503 error"
        case .timeout:
            return "Request timeout"
        case .noConnection:
            return "Internet is not available"
        case .lostConnection:
            return "Network connection was lost"
        case .noResponse:
            return "Response is empty"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

enum NoReply: Codable, Error {
    case emptyResponse
}
