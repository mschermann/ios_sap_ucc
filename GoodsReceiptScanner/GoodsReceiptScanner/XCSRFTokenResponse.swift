//
//  XCSRFTokenResponse.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/16/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct XCSRFTokenResponse {
    
    let responseStatus: SapGatewayClientMessages
    let httpStatusCode: Int?
    let token: XCSRFToken?
    let error: String?
    
    init(responseStatus: SapGatewayClientMessages,
         httpStatusCode: Int? = nil,
         token: XCSRFToken? = nil,
         error: Error? = nil) {
        
        self.responseStatus = responseStatus
        self.httpStatusCode = httpStatusCode
        self.token = token
        self.error = error?.localizedDescription
    }
    
}
