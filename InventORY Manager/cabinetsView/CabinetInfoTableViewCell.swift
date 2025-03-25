//
//  CabinetInfoTableViewCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 17.03.2025.
//

import Foundation
import UIKit

class CabinetInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var item: LocationItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        nameLabel.text = "(\(item!.rowid)) \(item!.storage!.name)"
        
        if item!.condition {
            conditionLabel.text = "✅"
        } else {
            conditionLabel.text = "❌"
        }    }
}
