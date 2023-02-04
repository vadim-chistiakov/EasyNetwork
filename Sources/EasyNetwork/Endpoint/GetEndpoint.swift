//
//  GetEndpoint.swift
//  
//
//  Created by Vadim Chistiakov on 04.02.2023.
//

import Foundation

public protocol GetEndpoint: Endpoint {}
public extension GetEndpoint {
    var method: RequestMethod {
        .get
    }
    
    var body: Body? {
        nil
    }
}
