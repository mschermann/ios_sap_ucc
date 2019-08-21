//
//  PickQuantityTableViewCell.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/12/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//
//  Adapted from https://digitalleaves.com/blog/2017/01/dynamic-uidatepickers-in-a-table-view/


import UIKit

protocol StockTypePickTableViewCellDelegate {
    
    func pickedStockType(cell: StockTypePickTableViewCell, indexPath: IndexPath, didPick row: Int, stockType: StockTypeElement)
    
}

class StockTypePickTableViewCell: UITableViewCell {

    @IBOutlet weak var picker: UIPickerView!
    
    public var pickerData = [StockTypeElement]()
    
    public var selectedRow: Int {
        get {
            return _selectedRow
        }
        set {
            setSelectedRow(newValue)
        }
    }
    
    private var _selectedRow: Int = 0
    
    var delegate: StockTypePickTableViewCellDelegate?
    
    public var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        picker.delegate = self
        picker.dataSource = self
        
    }
    
    func setSelectedRow(_ row: Int) {
        picker.selectRow(row, inComponent: 0, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension StockTypePickTableViewCell: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].value
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickedStockType(cell: self, indexPath: indexPath, didPick: row, stockType: pickerData[row])
    }
}

extension StockTypePickTableViewCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}

