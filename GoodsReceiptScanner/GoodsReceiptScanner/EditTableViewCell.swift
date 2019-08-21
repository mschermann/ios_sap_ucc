//
//  EditTableViewCell.swift
//  GoodsReceiptScanner
//
//  Created by Michael Schermann on 8/11/19.
//  Copyright © 2019 Michael Schermann. All rights reserved.
//

import UIKit

class enterQuantityTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var editTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(title: String, content: String, placeholder: String) {
        cellTitle.text = title
        editTextField.text = content
        editTextField.placeholder = placeholder
    }

}
