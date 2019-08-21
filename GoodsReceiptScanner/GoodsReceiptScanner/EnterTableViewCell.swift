//
//  EnterQuantityTableViewCell.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/12/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//
//  Adapted from https://digitalleaves.com/blog/2017/01/dynamic-uidatepickers-in-a-table-view/

import UIKit

protocol EnterTableViewCellDelegate: class {
    
    func enteredQuantity(detailText: String, changedValueTo value: String)
    func didBeginEnter(text: String)
}

class EnterTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var enterQuantityField: UITextField!
    @IBOutlet weak var enterQuantityLabel: UILabel!
    
    weak var delegate: EnterTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        enterQuantityField.delegate = self
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        self.delegate?.enteredQuantity(detailText: "Test", changedValueTo: sender.text ?? "")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String, detailText: String, picker: Bool) {
        self.enterQuantityField.placeholder = detailText
        self.enterQuantityLabel.text = text
        if picker {
            self.enterQuantityField.isUserInteractionEnabled = false
            self.selectionStyle = .default
        }
        else {
            self.enterQuantityField.isUserInteractionEnabled = true
            self.selectionStyle = .none
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.didBeginEnter(text: "Begins")
    }
    
}
