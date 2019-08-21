//
//  PO.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/10/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

struct PurchaseOrder: Codable, SapObject {
    
    var metaData: MetaData
    
    var inboundDelivery: String
    var sourceOfGr: String?
    var purchasingDocumentType: String?
    var purchasingDocumentTypeName: String?
    var documentDate: String?
    var postingDate: String?
    var deliveryDocumentByVendor: String?
    var billOfLading: String?
    var vendor: String
    var vendorName: String
    var supplyingPlant: String?
    var supplyingPlantName: String?
    var materialDocumentHeaderText: String?
    var tempKey: String?
    var versionForPrintingSlip: String?
    var header2Items: AssociatedPurchaseOrderItems
    
    enum CodingKeys: String, CodingKey {
        case metaData = "__metadata"
        case inboundDelivery = "InboundDelivery"
        case sourceOfGr = "SourceOfGR"
        case purchasingDocumentType = "PurchasingDocumentType"
        case purchasingDocumentTypeName = "PurchasingDocumentTypeName"
        case documentDate = "DocumentDate"
        case postingDate = "PostingDate"
        case deliveryDocumentByVendor = "DeliveryDocumentByVendor"
        case billOfLading = "BillOfLading"
        case vendor = "Vendor"
        case vendorName = "VendorName"
        case supplyingPlant = "SupplyingPlant"
        case supplyingPlantName = "SupplyingPlantName"
        case materialDocumentHeaderText = "MaterialDocumentHeaderText"
        case tempKey = "Temp_Key"
        case versionForPrintingSlip = "VersionForPrintingSlip"
        case header2Items = "Header2Items"
        
    }
    
}

struct AssociatedPurchaseOrderItems: Codable {
    var results: [PurchaseOrderItem?]?
}

extension PurchaseOrder {
    
    enum SectionBaseLabels: String {
        case purchaseOrderHeader = "Purchase Order"
        case purchaseOrderItem = "No Purchase Order Items available."
    }
    
    typealias Section = (id: String, label: String)
    
    var sections: [Section] {
        
        var sections = [
            Section(PurchaseOrderSectionIdentifiers.headerSectionIdentifier.rawValue, SectionBaseLabels.purchaseOrderHeader.rawValue),
            Section(PurchaseOrderSectionIdentifiers.itemSectionIdentifier.rawValue, SectionBaseLabels.purchaseOrderItem.rawValue)
        ]
        
        guard let items = self.header2Items.results as? [PurchaseOrderItem] else {
            return sections
        }
        
        _ = sections.popLast()
        
        items.forEach { (poItem) in
            sections.append(Section(PurchaseOrderSectionIdentifiers.itemSectionIdentifier.rawValue, "\(poItem.materialName) (\(poItem.material))"))
        }
        return sections
        
    }
    
    enum HeaderElementLabels: String {
        case poNumber = "Purchase Order Number"
        case vendor = "Vendor (Vendor ID)"
    }
    
    typealias HeaderElement = (label: String, value: String)
    
    var headerElements: [HeaderElement] {
        
        return [
            (HeaderElementLabels.poNumber.rawValue, self.inboundDelivery),
            (HeaderElementLabels.vendor.rawValue, "\(self.vendorName) (\(self.vendor))")
        ]
                
    }
    
    var purchaseOrderItems: [PurchaseOrderItem]? {
        
        guard let items:[PurchaseOrderItem] = self.header2Items.results as? [PurchaseOrderItem] else {
            return nil
        }
    
        return items
        
    }
    
    func getPurchaseOrderItemByTableViewSection(section: Int) -> PurchaseOrderItem? {
        
        guard section-1 >= 0 else {
            return nil
        }
        
        let index = section-1
        
        guard let poItem: PurchaseOrderItem = self.purchaseOrderItems?[index] else {
            return nil
        }
        
        return poItem
        
    }
    
    mutating func updatePurchaseOrderItem(section: Int, storageLocationElement: StorageLocationElement) {
        
        guard section-1 >= 0 else {
            return
        }
        
        let index = section-1
        
        self.header2Items.results?[index]?.storageLocation = storageLocationElement.id
        self.header2Items.results?[index]?.storageLocationName = storageLocationElement.name
        
    }
    
}

enum PurchaseOrderSectionIdentifiers: String {
    case headerSectionIdentifier = "Purchase Order Header"
    case itemSectionIdentifier = "Purchase Order Item"
}
