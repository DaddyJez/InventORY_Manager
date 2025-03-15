//
//  CabinetTableCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 15.03.2025.
//

import Foundation
import UIKit

class CabinetTableCell: UITableViewCell {
    weak var delegate: CabinetsControllerDelegate?
    
    @IBOutlet weak var responsibleLabel: UILabel!
    @IBOutlet weak var cabinetNumLabel: UILabel!
    
    var rowData: [String: String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with data: [String: String]) {
        self.rowData = data
        self.cabinetNumLabel.text = data["cabinetNum"]
        self.responsibleLabel.text = "\(data["responsibleName"]!) (\(data["responsible"]!))"
    }
}
