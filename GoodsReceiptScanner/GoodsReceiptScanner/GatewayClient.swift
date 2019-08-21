//
//  GatewayClient.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/14/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

final class GoodsReceiptApi {
    
    // Singleton
    static let shared = GoodsReceiptApi()

    // Facade
    private let sapGatewayClient = SapGatewayClient.shared
    
    private init() {
        
    }
    
    func getPurchaseOrder() {
    
    }
    
    func getStorageLocationsForPurchaseOrder () {
        
    }
    
    func recordGoodsReceipt () {
        
    }

}
