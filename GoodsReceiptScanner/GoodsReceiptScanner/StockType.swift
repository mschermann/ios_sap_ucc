//
//  StockType.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/20/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct StockType: Codable {
    
    var metaData: MetaData
    var inboundDelivery: String?
    var deliveryDocumentItem: String?
    var sourceOfGr: String?
    var controlOfBatchTableField: String?
    var stockType: String
    var stockTypeName: String
    var controlOfReasonCodeTableField: String?
    
    enum CodingKeys: String, CodingKey {
        case metaData = "__metadata"
        case inboundDelivery = "InboundDelivery"
        case deliveryDocumentItem = "DeliveryDocumentItem"
        case sourceOfGr = "SourceOfGR"
        case controlOfBatchTableField = "ControlOfBatchTableField"
        case stockType = "StockType"
        case stockTypeName = "StockTypeName"
        case controlOfReasonCodeTableField = "ControlOfReasonCodeTableField"
    }
    
}
