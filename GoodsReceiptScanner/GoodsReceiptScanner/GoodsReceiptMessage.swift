//
//  GRMessage.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/13/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//
//{"InboundDelivery":"4500000017","DocumentDate":"2019-08-06T00:00:00","PostingDate":"2019-08-06T00:00:00","SourceOfGR":"PURORD","DeliveryDocumentByVendor":"","MaterialDocumentHeaderText":"","Temp_Key":"4500000017GR06082019150400","BillOfLading":"","VersionForPrintingSlip":"0","Header2Items":[{"Material":"OHMT1013","InboundDelivery":"4500000017","DeliveryDocumentItem":"000010","DocumentItemText":"","QuantityInEntryUnit":"10","EntryUnit":"EA","OpenQuantity":"10","UnitOfMeasure":"EA","Plant":"MI00","StorageLocation":"TG00","StockType":"","Batch":"","AcctAssignmentCategory":"","AssetNumber":"","AssetNumberName":"","SubAssetNumber":"","GLAccount":"","GLAccountName":"","Project":"","ProjectDescription":"","GoodsMovementReasonCode":"0000"}]}

import Foundation

enum GoodsReceiptMessageError: Error, CustomStringConvertible{
    
    var description: String {
        switch self {
        case .noMaterial:
            return "No Material Found"
        case .checkEnteredValues:
            return "Please check your entered values."
        }
    }
    
    case noMaterial
    case checkEnteredValues
}

struct GoodsReceiptMessage: Codable {
    
    var inboundDelivery: String
    var documentDate: String
    var postingDate: String
    var sourceOfGr: String
    var deliveryDocumentByVendor: String
    var materialDocumentHeaderText: String
    var tempKey: String
    var billOfLading: String
    var versionForPrintingSlip: String
    var header2Items: [GoodsReceiptMessageItem]
    
    enum CodingKeys: String, CodingKey {
        case inboundDelivery = "InboundDelivery"
        case documentDate = "DocumentDate"
        case postingDate = "PostingDate"
        case sourceOfGr = "SourceOfGR"
        case deliveryDocumentByVendor = "DeliveryDocumentByVendor"
        case materialDocumentHeaderText = "MaterialDocumentHeaderText"
        case tempKey = "Temp_Key"
        case billOfLading = "BillOfLading"
        case versionForPrintingSlip = "VersionForPrintingSlip"
        case header2Items = "Header2Items"
    }
    
}
