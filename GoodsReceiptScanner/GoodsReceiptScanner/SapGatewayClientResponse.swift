//
//  ApiResponse.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/14/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct SapGatewayClientResponse {
    let responseStatus: SapGatewayClientMessages
    let data: Data?
    let error: String?
    let httpStatusCode: Int?
    let message: SapGatewayClientMessage?
    
    init(responseStatus: SapGatewayClientMessages,
         data: Data? = nil,
         error: Error? = nil,
         httpStatusCode: Int? = nil,
         message: SapGatewayClientMessage? = nil) {
        
        self.responseStatus = responseStatus
        if data != nil {
            self.data = data
        } else {
            let nodatareponse = "{\"detail\":\"No data.\"}"
            self.data = try? JSONEncoder().encode(nodatareponse)
        }
        self.error = error?.localizedDescription
        self.httpStatusCode = httpStatusCode
        self.message = message
    }
    
}
