//
//  SapGatewayClientResponseBody.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/16/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct SapGatewayClientResponseBody<T: Codable & SapObject>: Codable {
    
    var content: SapObjectResults<T>
    
    enum CodingKeys: String, CodingKey {
        case content = "d"
    }
}

struct SapObjectResults<T: Codable & SapObject>: Codable {
    
    var results: [T?]
    
}

struct MetaData: Codable {
    
    var id: String
    var uri: String
    var type: String
}

protocol SapObject {

    var metaData: MetaData {get set}
    
}
