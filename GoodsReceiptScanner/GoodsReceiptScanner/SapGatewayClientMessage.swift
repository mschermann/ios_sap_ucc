//
//  SAPMessage.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/10/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct SapGatewayClientMessage: Codable {
    
    var code: String
    var message: String
    var longtextURL: String?
    var severity: String
    var target: String
    var details: [String?]?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case longtextURL = "longtext_url"
        case severity
        case target
        case details
    }
    
}


