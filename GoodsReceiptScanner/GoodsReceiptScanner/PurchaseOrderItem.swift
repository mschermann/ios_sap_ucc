//
//  PurchaseOrderItem.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/20/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct PurchaseOrderItem: Codable, SapObject {
    
    var metaData: MetaData
    var inboundDelivery: String
    var deliveryDocumentItem: String?
    var sourceOfGr: String?
    var accountAssignmentCategory: String?
    var accountAssignmentCategoryName: String?
    var plant: String
    var plantName: String
    var storageLocation: String?
    var storageLocationName: String?
    var material: String
    var materialName: String
    var purchaseOrderItemText: String?
    var batch: String?
    var orderedQuantity: String
    var orderedQuantityUnit: String
    var openQuantity: String
    var unitOfMeasure: String
    var quantityInEntryUnit: String?
    var entryUnit: String?
    var stockType: String?
    var stockTypeName: String?
    var project: String?
    var projectDescription: String?
    var glAccount: String?
    var glAccountName: String?
    var unloadingPointName: String?
    var goodsReceiptName: String?
    var deliveryCompleted: String?
    var functionalArea: String?
    var profitCenter: String?
    var profitCenterName: String?
    var costCenter: String?
    var costCenterName: String?
    var salesOrder: String?
    var salesOrderItem: String?
    var documentItemText: String?
    var orderId: String?
    var inventorySpecialStockType: String?
    var inventorySpecialStockTypeName: String?
    var isConsumptionMovement: Bool?
    var goodsMovementReasonCode: String?
    var assetNumber: String?
    var assetNumberName: String?
    var subAssetNumber: String?
    var item2StockTypes: AssociatedStockTypes?
    
    enum CodingKeys: String, CodingKey {
        case metaData = "__metadata"
        case inboundDelivery = "InboundDelivery"
        case deliveryDocumentItem = "DeliveryDocumentItem"
        case sourceOfGr = "SourceOfGR"
        case accountAssignmentCategory = "AcctAssignmentCategory"
        case accountAssignmentCategoryName = "AcctAssignmentCategoryName"
        case plant = "Plant"
        case plantName = "PlantName"
        case storageLocation = "StorageLocation"
        case storageLocationName = "StorageLocationName"
        case material = "Material"
        case materialName = "MaterialName"
        case purchaseOrderItemText = "PurchaseOrderItemText"
        case batch = "Batch"
        case orderedQuantity = "OrderedQuantity"
        case orderedQuantityUnit = "OrderedQuantityUnit"
        case openQuantity = "OpenQuantity"
        case unitOfMeasure = "UnitOfMeasure"
        case quantityInEntryUnit = "QuantityInEntryUnit"
        case entryUnit = "EntryUnit"
        case stockType = "StockType"
        case stockTypeName = "StockTypeName"
        case project = "Project"
        case projectDescription = "ProjectDescription"
        case glAccount = "GLAccount"
        case glAccountName = "GLAccountName"
        case unloadingPointName = "UnloadingPointName"
        case goodsReceiptName = "GoodsRecipientName"
        case deliveryCompleted = "DeliveryCompleted"
        case functionalArea = "FunctionalArea"
        case profitCenter = "ProfitCenter"
        case profitCenterName = "ProfitCenterName"
        case costCenter = "CostCenter"
        case costCenterName = "CostCenterName"
        case salesOrder = "SalesOrder"
        case salesOrderItem = "SalesOrderItem"
        case documentItemText = "DocumentItemText"
        case orderId = "OrderID"
        case inventorySpecialStockType = "InventorySpecialStockType"
        case inventorySpecialStockTypeName = "InventorySpecialStockTypeName"
        case isConsumptionMovement = "IsConsumptionMovement"
        case goodsMovementReasonCode = "GoodsMovementReasonCode"
        case assetNumber = "AssetNumber"
        case assetNumberName = "AssetNumberName"
        case subAssetNumber = "SubAssetNumber"
        case item2StockTypes = "Item2StockTypes"
        
    }
}

struct AssociatedStockTypes: Codable {
    var results: [StockType]?
}

typealias PurchaseOrderItemElement = (order: Int, action: PurchaseOrderItemElementAction, label: String, value: String)

typealias StockTypeElement = (label: String, value: String)

enum PurchaseOrderItemOrder: Int {
    case warehouse = 0
    case openOrdered = 1
    case storageLocation = 2
    case stockType = 3
    case deliveryQuantity = 4
    
}

extension PurchaseOrderItem {
    
    var itemsElements: [PurchaseOrderItemElement] {
        
        return [
            (PurchaseOrderItemOrder.warehouse.rawValue, PurchaseOrderItemElementAction.display,
             PurchaseOrderItemElementLabels.warehouse.rawValue,
             "\(self.plantName) (\(self.plant))"),
            (PurchaseOrderItemOrder.openOrdered.rawValue, PurchaseOrderItemElementAction.display, PurchaseOrderItemElementLabels.openOrdered.rawValue, "\(self.orderedQuantity) of \(self.openQuantity)"),
            (PurchaseOrderItemOrder.storageLocation.rawValue, PurchaseOrderItemElementAction.fetch, PurchaseOrderItemElementLabels.storageLocation.rawValue, PurchaseOrderItemElementLabels.storageLocation.description),
            (PurchaseOrderItemOrder.stockType.rawValue, PurchaseOrderItemElementAction.select, PurchaseOrderItemElementLabels.stockType.rawValue, PurchaseOrderItemElementLabels.stockType.description),
            (PurchaseOrderItemOrder.deliveryQuantity.rawValue, PurchaseOrderItemElementAction.enter, PurchaseOrderItemElementLabels.deliveryQuantity.rawValue, PurchaseOrderItemElementLabels.deliveryQuantity.description)
            
        ]

    }
    
    public func getPurchaseOrderItemElement(index: Int) -> PurchaseOrderItemElement? {
        
        guard index < self.itemsElements.count else {
            return nil
        }
        
        return self.itemsElements[index]
        
    }
    
    var stockTypes: [StockTypeElement] {
        
        guard let stockTypes:[StockType] = self.item2StockTypes?.results else {
            return [StockTypeElement]()
        }
        
        var stockTypeElements = [StockTypeElement]()
        
        stockTypes.forEach { (stockType: StockType) in
            stockTypeElements.append(StockTypeElement(stockType.stockType, stockType.stockTypeName))
        }
        
        return stockTypeElements
    }
    
}

enum PurchaseOrderItemElementAction: String {
    
    case display = "display"
    case fetch = "fetch"
    case select = "select"
    case enter = "enter"
    
}

enum PurchaseOrderItemElementLabels: String, CustomStringConvertible {
    var description: String {
        switch self {
        case .stockType, .storageLocation:
            return "Select"
        case .deliveryQuantity:
            return "Enter"
        default:
            return ""
        }
    }
    
    case warehouse = "Warehouse (ID)"
    case openOrdered = "Open / Ordered"
    case storageLocation = "Storage Location"
    case stockType = "Stock Type"
    case deliveryQuantity = "Delivery Quantity"
}
