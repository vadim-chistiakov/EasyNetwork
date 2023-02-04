//
//  Endpoint.swift
//  EasyNetwork
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

import Foundation

public typealias Header = [String: String]
public typealias Body = [String: String]

public protocol Endpoint {
    var scheme: Scheme { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: Header? { get }
    var body: Body? { get }
}

public extension Endpoint {
    var scheme: Scheme {
        .https
    }
}
