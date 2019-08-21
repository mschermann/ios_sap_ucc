//
//  PurchaseOrderTableViewController.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/10/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import UIKit

enum PurchaseOrderCells: String, CustomStringConvertible {
     
     var description: String {
          switch self {
          case .pickerCell:
               return "PickTableViewCell"
          case .enterCell:
               return "EnterTableViewCell"
          default:
               return "Cell"
          }
     }
     case pickerCell = "pickerCell"
     case enterCell = "enterCell"
     case itemCell = "itemCell"
     case headerCell = "headerCell"
     
}

enum PurchaseOrderLabels: String {
     
     case post = "Post"
     case storageLocation = "Storage Location"
}

class PurchaseOrderTableViewController: UITableViewController {

     var purchaseOrder: PurchaseOrder!
     
     var pickerIndexPath: IndexPath?
    
     var pickerVisible: Bool { return pickerIndexPath != nil }
    
     override func viewDidLoad() {
          
          super.viewDidLoad()

          tableView.register(UINib(nibName: PurchaseOrderCells.pickerCell.description, bundle: nil), forCellReuseIdentifier: PurchaseOrderCells.pickerCell.rawValue)
          tableView.register(UINib(nibName: PurchaseOrderCells.enterCell.description, bundle: nil), forCellReuseIdentifier: PurchaseOrderCells.enterCell.rawValue)
        
          navigationItem.rightBarButtonItem = UIBarButtonItem(title: PurchaseOrderLabels.post.rawValue, style: .plain, target: self, action: #selector(postGR(_:)))
          
          //navigationItem.rightBarButtonItem?.isEnabled = false
     
     }
     
     // MARK: - Table view data source
     
     override func numberOfSections(in tableView: UITableView) -> Int {
          return purchaseOrder.sections.count
     }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
          switch purchaseOrder.sections[section].id {
          case PurchaseOrderSectionIdentifiers.headerSectionIdentifier.rawValue:
               return purchaseOrder.headerElements.count
          default:
               // section 0 is header, items are section 1 to n
               guard let item = purchaseOrder.purchaseOrderItems?[section-1] else {
                    return 0
               }
               guard section == pickerIndexPath?.section else {
                    return item.itemsElements.count
               }
               // one more cell for the picker
               return pickerVisible ? item.itemsElements.count + 1 : item.itemsElements.count
          }
     
     }
     
     override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          return purchaseOrder.sections[section].label
     }
     
     @objc func postGR(_ sender: UIButton)  {
          
          self.removePicker()
          
          self.getGoodsReceiptMessage { (result: Result<GoodsReceiptMessage, GoodsReceiptMessageError>) in
               switch result {
                    case .success(let message):
                    
                         do {
                              let encoder = JSONEncoder()
                              let data = try encoder.encode(message)
                              
                              print(String(data: data, encoding: .utf8)!)
                              
                              GoodsReceiptApi.shared.recordGoodsReceipt(goodsReceiptMessage: data) { (result: Result<MaterialDocument, GoodsReceiptApiMessages>) in
                                   switch result {
                                   case .success(let document):
                                        DispatchQueue.main.async {
                                             self.presentSuccessMessage(document)
                                        }
                                   case .failure(let error):
                                        DispatchQueue.main.async {
                                             self.presentMessage(error)
                                        }
                                        
                                   }
                              }
                         }
                         catch let error {
                              print("\(error)")
                         }
                    
                    case .failure(let error):
                         DispatchQueue.main.async {
                              self.presentMessage(error)
                         }
                    }
          }
          
     }
     
     private func presentSuccessMessage(_ message: MaterialDocument) {
          let alertController = UIAlertController(title: ControllerMessages.sapMessage.rawValue, message: message.id, preferredStyle: .alert)
          let OKAction = UIAlertAction(title: ControllerMessages.scanNextPurchaseOrder.rawValue, style: .default) { action in
               DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
               }
          }
          alertController.addAction(OKAction)
          
          present(alertController, animated: true, completion: nil)
     }
     
     private func presentMessage(_ error: GoodsReceiptMessageError) {
          let alertController = UIAlertController(title: ControllerMessages.invalidEntry.rawValue, message: error.description, preferredStyle: .alert)
          let OKAction = UIAlertAction(title: ControllerMessages.ok.rawValue, style: .default) { action in
               
          }
          alertController.addAction(OKAction)
          
          present(alertController, animated: true, completion: nil)
     }

     private func presentMessage(_ error: GoodsReceiptApiMessages) {
          let alertController = UIAlertController(title: ControllerMessages.sapMessage.rawValue, message: error.description, preferredStyle: .alert)
          let OKAction = UIAlertAction(title: ControllerMessages.ok.rawValue, style: .default) { action in
               
          }
          alertController.addAction(OKAction)
          
          present(alertController, animated: true, completion: nil)
     }
     
     private func getErrorCell(indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.headerCell.rawValue, for: indexPath)
          cell.textLabel?.text = "Could not find any Purchase Order Items."
          cell.detailTextLabel?.text = ""
          cell.isUserInteractionEnabled = false
          return cell
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
          switch purchaseOrder.sections[indexPath.section].id {
               
          // Header
          case PurchaseOrderSectionIdentifiers.headerSectionIdentifier.rawValue:
               let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.headerCell.rawValue, for: indexPath)
               cell.textLabel?.text = purchaseOrder.headerElements[indexPath.row].value
               cell.detailTextLabel?.text = purchaseOrder.headerElements[indexPath.row].label
               cell.isUserInteractionEnabled = false
               return cell
          
          // Items
          case PurchaseOrderSectionIdentifiers.itemSectionIdentifier.rawValue:
               guard let poItem: PurchaseOrderItem = purchaseOrder.getPurchaseOrderItemByTableViewSection(section: indexPath.section) else {
                    return self.getErrorCell(indexPath: indexPath)
               }
               guard let poItemElement: PurchaseOrderItemElement = poItem.getPurchaseOrderItemElement(index: indexPath.row) else {
                    return self.getErrorCell(indexPath: indexPath)
               }
               
               if pickerVisible && pickerIndexPath! == indexPath {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.pickerCell.rawValue, for: indexPath) as! StockTypePickTableViewCell
                    cell.delegate = self
                    cell.indexPath = indexPath
                    cell.pickerData = poItem.stockTypes
                    cell.selectedRow = 0
                    return cell
               }
               else {
               
                    switch poItemElement.action {
                         case PurchaseOrderItemElementAction.display:
                               let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.itemCell.rawValue, for: indexPath)
                               cell.textLabel?.text = poItemElement.label
                               cell.detailTextLabel?.text = poItemElement.value
                               cell.isUserInteractionEnabled = false
                               return cell
                         case PurchaseOrderItemElementAction.fetch:
                               let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.itemCell.rawValue, for: indexPath)
                               let activityIndicator = UIActivityIndicatorView(style: .white)
                               activityIndicator.frame = self.view.bounds
                               self.view.addSubview(activityIndicator)
                               
                               activityIndicator.startAnimating()
                               self.getStorageLocationForPurchaseOrderItem(poItem: poItem) { (sle: StorageLocationElement) in
                                   DispatchQueue.main.async {
                                        activityIndicator.removeFromSuperview()
                                        self.purchaseOrder.updatePurchaseOrderItem(section: indexPath.section, storageLocationElement: StorageLocationElement(id: sle.id, name: sle.name))
                                        cell.detailTextLabel?.text = "\(sle.name) (\(sle.id))"
                                        cell.textLabel?.text = PurchaseOrderLabels.storageLocation.rawValue
                                   }
                              }
                              cell.isUserInteractionEnabled = false
                              return cell
                         case PurchaseOrderItemElementAction.enter:
                              let cell = self.tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.enterCell.rawValue, for: indexPath) as! EnterTableViewCell
                              cell.delegate = self
                              cell.configure(text: poItemElement.label, detailText: poItemElement.value, picker: false)
                              return cell
                         case PurchaseOrderItemElementAction.select:
                              let cell = self.tableView.dequeueReusableCell(withIdentifier: PurchaseOrderCells.enterCell.rawValue, for: indexPath) as! EnterTableViewCell
                              cell.delegate = self
                              cell.configure(text: poItemElement.label, detailText: poItemElement.value, picker: true)
                              return cell
                    }
               }
          
          default:
               return self.getErrorCell(indexPath: indexPath)
        
          }
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
          tableView.deselectRow(at: indexPath, animated: true)
          
          guard let poItem: PurchaseOrderItem = purchaseOrder.getPurchaseOrderItemByTableViewSection(section: indexPath.section) else {
               return
          }
          
          guard let poItemElement: PurchaseOrderItemElement = poItem.getPurchaseOrderItemElement(index: indexPath.row) else {
               return
          }
          
          guard poItemElement.action == PurchaseOrderItemElementAction.select else {
               return
          }
          
          self.view.endEditing(true)
          
          guard pickerVisible else{
               showPicker(indexPath: indexPath)
               return
          }
          
          guard indexPath.row == (pickerIndexPath?.row ?? 0) - 1 && indexPath.section == pickerIndexPath?.section else {
               removePicker()
               return
          }
          
          removePicker()
          
     }
     
}

typealias PickerExtension = PurchaseOrderTableViewController

extension PickerExtension {
    
    func removePicker() {
        
        guard pickerVisible else {return}

        tableView.beginUpdates()
        tableView.deleteRows(at: [pickerIndexPath!], with: .fade)
        self.pickerIndexPath = nil
        tableView.endUpdates()

    }
    
    func showPicker(indexPath: IndexPath) {
        
        tableView.beginUpdates()
        self.pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        tableView.insertRows(at: [self.pickerIndexPath!], with: .fade)
        tableView.endUpdates()

    }
     
}

extension PurchaseOrderTableViewController: StockTypePickTableViewCellDelegate {

     func pickedStockType(cell: StockTypePickTableViewCell, indexPath: IndexPath, didPick row: Int, stockType: StockTypeElement) {
        print("Value changed for row \(indexPath.row) to \(stockType.value)")
          let indextPathToChange = IndexPath(row: indexPath.row - 1, section: indexPath.section)
          let cellToChange = tableView.cellForRow(at: indextPathToChange) as! EnterTableViewCell
          cellToChange.enterQuantityField.text = stockType.value
     }
     
}

extension PurchaseOrderTableViewController: EnterTableViewCellDelegate {
    
     func enteredQuantity(detailText: String, changedValueTo value: String) {
          print("Value changed for label \(detailText) to \(value)")
          //self.tableView.reloadData()
     }
    
    
    func didBeginEnter(text: String ) {
        removePicker()
    }
}

typealias GoodsReceiptExtension = PurchaseOrderTableViewController

extension GoodsReceiptExtension {
     
     private func getStorageLocationForPurchaseOrderItem(poItem: PurchaseOrderItem, completion: @escaping (StorageLocationElement) -> Void) {
          
          GoodsReceiptApi.shared.getStorageLocationsForPurchaseOrderItem(purchaseOrderItem: poItem) { (result: Result<StorageLocation, GoodsReceiptApiMessages>) in
               
               switch result {
               case .success(let storageLocation):
                    completion(storageLocation.storageLocationElement)
               case .failure(let error):
                    DispatchQueue.main.async {
                         self.presentMessage(error)
                    }
                    
               }
               
          }
     }
     
     private func getGoodsReceiptMessage(completion: @escaping (Result<GoodsReceiptMessage, GoodsReceiptMessageError>) -> Void) {
          
          var goodsReceiptMessageItems = [GoodsReceiptMessageItem]()
          
          guard let purchaseOrderItems: [PurchaseOrderItem] = purchaseOrder.purchaseOrderItems else {
               completion(.failure(.noMaterial))
               return
          }
          
          DispatchQueue.main.async {
          
               for (index, item) in purchaseOrderItems.enumerated() {
               
                    let section = index + 1
               
                    let stockTypeName = (self.tableView.cellForRow(at: IndexPath(item: PurchaseOrderItemOrder.stockType.rawValue, section: section)) as! EnterTableViewCell).enterQuantityField.text ?? ""
                    let enteredQuantity = (self.tableView.cellForRow(at: IndexPath(item: PurchaseOrderItemOrder.deliveryQuantity.rawValue, section: section)) as! EnterTableViewCell).enterQuantityField.text ?? ""
                    
                    guard stockTypeName != "" || enteredQuantity != "" else {
                         break
                    }
                    
                    var stockType = ""
                    item.stockTypes.forEach({ (element: (label: String, value: String)) in
                         if element.value == stockTypeName {
                              stockType = element.label
                         }
                    })
                    
                    let entryQuantityUnit = item.orderedQuantityUnit
                    let plant = item.plant
                    let storageLocation = item.storageLocation ?? ""
                    let openQuantity = item.openQuantity
                    let openQuantityUnit = item.unitOfMeasure
                    
                    //               {"Material":"OHMT1013","InboundDelivery":"4500000017","DeliveryDocumentItem":"000010","DocumentItemText":"","QuantityInEntryUnit":"10","EntryUnit":"EA","OpenQuantity":"10","UnitOfMeasure":"EA","Plant":"MI00","StorageLocation":"TG00","StockType":"","Batch":"","AcctAssignmentCategory":"","AssetNumber":"","AssetNumberName":"","SubAssetNumber":"","GLAccount":"","GLAccountName":"","Project":"","ProjectDescription":"","GoodsMovementReasonCode":"0000"}
                    
                    let goodsReceiptMessageItem = GoodsReceiptMessageItem(material: item.material, inboundDelivery: item.inboundDelivery, deliveryDocumentItem: "0000\(index+1)0", documentItemText: "", quantityInEntryUnit: enteredQuantity, entryUnit: entryQuantityUnit, openQuantity: openQuantity , unitOfMeasure: openQuantityUnit, plant: plant, storageLocation: storageLocation, stockType: stockType, batch: "", accountAssignmentCategory: "", assetNumber: "", assetNumberName: "", subAssetNumber: "", glAccount: "", glAccountName: "", project: "", projectDescription: "", goodsMovementReasonCode: "0000")
               
                    goodsReceiptMessageItems.append(goodsReceiptMessageItem)

               }
               
               //          {"InboundDelivery":"4500000017","DocumentDate":"2019-08-06T00:00:00","PostingDate":"2019-08-06T00:00:00","SourceOfGR":"PURORD","DeliveryDocumentByVendor":"","MaterialDocumentHeaderText":"","Temp_Key":"4500000017GR06082019150400","BillOfLading":"","VersionForPrintingSlip":"0","Header2Items"
               
               guard goodsReceiptMessageItems.count >= 1 else {
                    completion(.failure(GoodsReceiptMessageError.checkEnteredValues))
                    return
               }
               
               let message = GoodsReceiptMessage(inboundDelivery: self.purchaseOrder.inboundDelivery,
                                                 documentDate: self.getDocumentDate(date: Date()),
                                                 postingDate: self.getDocumentDate(date: Date()),
                                                 sourceOfGr: "PURORD",
                                                 deliveryDocumentByVendor: "",
                                                 materialDocumentHeaderText: "",
                                                 tempKey: self.getTempKey(poNumber: self.purchaseOrder.inboundDelivery, date: Date()),
                                                 billOfLading: "",
                                                 versionForPrintingSlip: "0",
                                                 header2Items: goodsReceiptMessageItems)
               
               print(message)
               completion(.success(message))
               
          }
          
     }
     
     private func getDocumentDate(date: Date) -> String {
          let dateformat = DateFormatter()
          dateformat.dateFormat = "yyyy-MM-dd"
          return dateformat.string(from: date) + "T00:00:00"
     }
     
     private func getTempKey(poNumber: String, date: Date) -> String {
          let dateformat = DateFormatter()
          dateformat.dateFormat = "ddMMyyyyHHmmss"
          return "\(poNumber)GR\(dateformat.string(from: date))"
     }
     
}
