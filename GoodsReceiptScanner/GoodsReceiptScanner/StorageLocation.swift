//
//  StorageLocations.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/12/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct StorageLocation: Codable, SapObject {
    
    var metaData: MetaData
    var material: String
    var plant: String
    var storageLocation: String
    var storageLocationName: String
    var calendarDate: String?
    var currentStock: String?
    var qualityInspectionStockQuantity: String?
    var returnsBlockedStockQuantity: String?
    var transferStockStorageLocQty: String?
    var blockedStockQuantity: String?
    var restrictedStockQuantity: String?
    var baseUnit: String?
    
    enum CodingKeys: String, CodingKey {
        case metaData = "__metadata"
        case material = "Material"
        case plant = "Plant"
        case storageLocation = "StorageLocation"
        case storageLocationName = "StorageLocationName"
        case calendarDate = "CalendarDate"
        case currentStock = "CurrentStock"
        case qualityInspectionStockQuantity = "QualityInspectionStockQuantity"
        case returnsBlockedStockQuantity = "ReturnsBlockedStockQuantity"
        case transferStockStorageLocQty = "TransferStockStorageLocQty"
        case blockedStockQuantity = "BlockedStockQuantity"
        case restrictedStockQuantity = "RestrictedStockQuantity"
        case baseUnit = "BaseUnit"

    }
    
}

typealias StorageLocationElement = (id: String, name: String)

extension StorageLocation {
    
    var storageLocationElement: StorageLocationElement {
        
        return StorageLocationElement(id: self.storageLocation, name: self.storageLocationName)
        
    }
    
}
