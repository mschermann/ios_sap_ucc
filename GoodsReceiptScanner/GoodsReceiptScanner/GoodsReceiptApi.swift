//
//  GoodsReceiptApi
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/14/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import Foundation

typealias PurchaseOrderNumber = String

enum GoodsReceiptEndpoints: String {
    
    case purchaseOrderDocument = "/MMIM_GR4PO_DL_SRV/GR4PO_DL_Headers"
    case storageLocations = "/MMIM_MATERIAL_DATA_SRV/MaterialStorLocHelps"
    
}

final class GoodsReceiptApi {
    
    // MARK: Facade
    private let sapGatewayClient = SapGatewayClient.shared
    
    // MARK: Singleton
    public static let shared = GoodsReceiptApi()
    
    private init() { }

    
    func getPurchaseOrder(purchaseOrderNumber: PurchaseOrderNumber, completion: @escaping (Result<PurchaseOrder, GoodsReceiptApiMessages>) -> Void) {
        
        let queryItems = [
            SapQueryItem(name: SapQueryItemKeys.expand.rawValue, value: "Header2Items,Header2Items/Item2StockTypes"),
            SapQueryItem(name: SapQueryItemKeys.filter.rawValue, value: "SourceOfGR eq 'PURORD' and InboundDelivery eq '\(purchaseOrderNumber)'")
        ]
        
        sapGatewayClient.get(endpoint: GoodsReceiptEndpoints.purchaseOrderDocument.rawValue, queryItems: queryItems) { (response: SapGatewayClientResponse) in
            
            guard response.responseStatus == SapGatewayClientMessages.success else {
                
                if let message = response.message {
                    
                    switch message.code {
                    case GoodsReceiptApiMessages.poDoesNotExist.rawValue:
                        completion(.failure(GoodsReceiptApiMessages.poDoesNotExist))
                    case GoodsReceiptApiMessages.poClosed.rawValue:
                        completion(.failure(GoodsReceiptApiMessages.poClosed))
                    default:
                        completion(.failure(GoodsReceiptApiMessages.unknownError))
                    }
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result:SapGatewayClientResponseBody = try decoder.decode(SapGatewayClientResponseBody<PurchaseOrder>.self, from: response.data!)
                
                guard result.content.results.count <= 1 else {
                    completion(.failure(GoodsReceiptApiMessages.moreThanOnePO))
                    return
                }
                
                guard let poObject: PurchaseOrder = result.content.results[0] else {
                    completion(.failure(GoodsReceiptApiMessages.noPoFound))
                    return
                }
                
                completion(.success(poObject))
                
            } catch let error {
                print("\(error)")
            }
            
            
        }
    }
    
    func getStorageLocationsForPurchaseOrderItem (purchaseOrderItem: PurchaseOrderItem, completion: @escaping (Result<StorageLocation, GoodsReceiptApiMessages>) -> Void) {
        
        let queryItems = [
            SapQueryItem(name: SapQueryItemKeys.filter.rawValue, value: "Material eq '\(purchaseOrderItem.material)' and Plant eq '\(purchaseOrderItem.plant)'")
        ]
        
        sapGatewayClient.get(endpoint: GoodsReceiptEndpoints.storageLocations.rawValue, queryItems: queryItems) { (response: SapGatewayClientResponse) in
            
            guard response.responseStatus == SapGatewayClientMessages.success else {
            
                if let message = response.message {
                    
                    switch message.code {
                    case GoodsReceiptApiMessages.noResultsForSelection.rawValue:
                        completion(.failure(GoodsReceiptApiMessages.noResultsForSelection))
                    default:
                        completion(.failure(GoodsReceiptApiMessages.unknownError))
                    }
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result:SapGatewayClientResponseBody = try decoder.decode(SapGatewayClientResponseBody<StorageLocation>.self, from: response.data!)
                
                guard result.content.results.count <= 1 else {
                    completion(.failure(GoodsReceiptApiMessages.materialNotMaintainedInPlant))
                    return
                }
                
                guard let storageLocation: StorageLocation = result.content.results[0] else {
                    completion(.failure(GoodsReceiptApiMessages.noResultsForSelection))
                    return
                }
                
                completion(.success(storageLocation))
                
            } catch let error {
                print("\(error)")
            }
            
            
            //
        }
        
    }
    
    func recordGoodsReceipt (goodsReceiptMessage payload: Data, completion: @escaping (Result<MaterialDocument, GoodsReceiptApiMessages>) -> Void) {
        
        sapGatewayClient.post(endpoint: GoodsReceiptEndpoints.purchaseOrderDocument.rawValue, payload: payload) { (response: SapGatewayClientResponse) in
            
            guard response.responseStatus == SapGatewayClientMessages.success else {
                
                if let message = response.message {
                    
                    switch message.code {
                    case GoodsReceiptApiMessages.goodsReceiptRecorded.rawValue:
                        completion(.success(MaterialDocument(id: message.message)))
                    case GoodsReceiptApiMessages.goodsReceiptWasAlreadyRecorded.rawValue:
                        completion(.failure(GoodsReceiptApiMessages.goodsReceiptWasAlreadyRecorded))
                    case GoodsReceiptApiMessages.deliveryExceedsOrderedQuantity.rawValue:
                        completion(.failure(GoodsReceiptApiMessages.deliveryExceedsOrderedQuantity))
                    default:
                        completion(.failure(GoodsReceiptApiMessages.unknownError))
                    }
                }
                return
            }
            
        }
        
    }

}

public enum GoodsReceiptApiMessages: String, Error, CustomStringConvertible {
    public var description: String {
        switch self {
        case .poClosed:
            return "Purchase order is already closed."
        case .poDoesNotExist:
            return "Purchase order does not exist."
        case .moreThanOnePO:
            return "More than one purchase order."
        case .noPoFound:
            return "Could not find purchase order."
        case .unknownError:
            return "An unknown error occured."
        case .noResultsForSelection:
            return "No storage location available."
        case .materialNotMaintainedInPlant:
            return "This material is not maintained for this storage facility."
        case .goodsReceiptRecorded:
            return "Goods Receipt was recorded."
        case .goodsReceiptWasAlreadyRecorded:
            return "Goods Receipt was already recorded."
        case .deliveryExceedsOrderedQuantity:
            return "The delivered quantity exceeds the ordered quantity. Please check."
        }
    }
    
    case poClosed = "M7/064"
    case poDoesNotExist = "06/019"
    case moreThanOnePO = "More than one purchase order."
    case unknownError = "An unknown error occured."
    case noPoFound = "Could not find purchase order."
    case noResultsForSelection = "M7/902"
    case materialNotMaintainedInPlant = "Material Not Maintained In Plant."
    case goodsReceiptRecorded = "MIGO/012"
    case goodsReceiptWasAlreadyRecorded = "MBND_CLOUD/002"
    case deliveryExceedsOrderedQuantity = "M7/022"
    
}
