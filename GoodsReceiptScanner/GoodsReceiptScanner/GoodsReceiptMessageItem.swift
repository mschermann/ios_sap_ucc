//
//  GRMessageItem.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/20/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct GoodsReceiptMessageItem: Codable {
    
    var material: String
    var inboundDelivery: String
    var deliveryDocumentItem: String
    var documentItemText: String
    var quantityInEntryUnit: String
    var entryUnit: String
    var openQuantity: String
    var unitOfMeasure: String
    var plant: String
    var storageLocation: String
    var stockType: String
    var batch: String
    var accountAssignmentCategory: String
    var assetNumber: String
    var assetNumberName: String
    var subAssetNumber: String
    var glAccount: String
    var glAccountName: String
    var project: String
    var projectDescription: String
    var goodsMovementReasonCode: String
    
    //{"Material":"OHMT1013","InboundDelivery":"4500000017","DeliveryDocumentItem":"000010","DocumentItemText":"","QuantityInEntryUnit":"10","EntryUnit":"EA","OpenQuantity":"10","UnitOfMeasure":"EA","Plant":"MI00","StorageLocation":"TG00","StockType":"","Batch":"","AcctAssignmentCategory":"","AssetNumber":"","AssetNumberName":"","SubAssetNumber":"","GLAccount":"","GLAccountName":"","Project":"","ProjectDescription":"","GoodsMovementReasonCode":"0000"}
    
    
    enum CodingKeys: String, CodingKey {
        case material = "Material"
        case inboundDelivery = "InboundDelivery"
        case deliveryDocumentItem = "DeliveryDocumentItem"
        case documentItemText = "DocumentItemText"
        case quantityInEntryUnit = "QuantityInEntryUnit"
        case entryUnit = "EntryUnit"
        case openQuantity = "OpenQuantity"
        case unitOfMeasure = "UnitOfMeasure"
        case plant = "Plant"
        case storageLocation = "StorageLocation"
        case stockType = "StockType"
        case batch = "Batch"
        case accountAssignmentCategory = "AcctAssignmentCategory"
        case assetNumber = "AssetNumber"
        case assetNumberName = "AssetNumberName"
        case subAssetNumber = "SubAssetNumber"
        case glAccount = "GLAccount"
        case glAccountName = "GLAccountName"
        case project = "Project"
        case projectDescription = "ProjectDescription"
        case goodsMovementReasonCode = "GoodsMovementReasonCode"
        
    }
    
    
}
