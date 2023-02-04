//
//  PostEndpoint.swift
//  
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

import Foundation

public protocol PostEndpoint: Endpoint {}
public extension PostEndpoint {
    var method: RequestMethod {
        .post
    }
}
